# Embedded Target Workflow

A workflow for agent-assisted development against a remote embedded Linux target, where code executes only on-device (via ssh), bugs are frequently environment-dependent (physical/network conditions, noisy radio links, UDP), and the dominant traffic is video. Companion to `agentic-dev-workflow.md`; this document covers what is specific to the embedded loop.

## Principles

1. **Script the loop.** The write→compile→deploy→run→collect cycle stays hands-on only as long as it lives in someone's head as procedural knowledge. Every step becomes a script with machine-readable output; then an agent can drive the entire cycle unattended.
2. **Occurrences are scarce.** For environment-dependent bugs, the limiting resource is not execution time but occurrences of the triggering condition. The loop is designed to extract maximum information per occurrence (capture-first) and to synthesize the condition on demand where possible (fault injection).
3. **Execution is the success signal.** A fix is done when a checked-in repro passes on-device, never when the diff looks right.
4. **Headers carry most of the diagnostic value.** Protocol and timing bugs live in headers, sequence numbers, and timestamps; the video payload is enormous by comparison and rarely needed to diagnose them. Capture headers always; capture payload as a deliberate exception (content-corruption bugs), not a default.

## The Harness

A small command inventory, each a script in `harness/`, each returning a structured exit code and writing artifacts to a predictable location. Sketches; implementations to be filled in per project.

```bash
# harness/build.sh        — cross-compile; exit nonzero on failure
# harness/deploy.sh       — language-aware deploy (see Stack Policy):
#                           Python: rsync delta + `uv sync` on-device; Rust: build .deb,
#                           dpkg -i, systemctl restart. ssh ControlMaster throughout.
# harness/run.sh <script> — execute a repro/test script on-device with hard timeout;
#                           pull back exit code + stdout/stderr
# harness/collect-diag.sh — bundle journalctl, dmesg, app logs, counters, version info,
#                           recent pcap ring window → one timestamped tarball
# harness/device-reset.sh — restore known state: restart services, clear scratch,
#                           clean redeploy; run before every repro
# harness/backtrace.sh    — non-interactive crash analysis: gdb -batch / gdbserver
#                           against core or live pid → text backtrace
# harness/loop.sh <repro> — build → deploy → device-reset → run → collect-diag;
#                           the single command an agent iterates with
```

Requirements that make these agent-compatible:
- **Hard timeouts everywhere.** A device hang must fail the run, never stall the caller.
- **Cores enabled on-device**; `backtrace.sh` makes crashes yield text, not an interactive session.
- **Idempotent reset.** Agent-driven runs on a stateful device drift (leftover processes, half-deployed binaries); without reset-before-run, the agent chases residue from its own previous attempts.

## Repro Library

Every bug gets `repros/issue-N.sh`: runs on-device, asserts, exits 0/1.

- The reproduce-first gate applies on-target: no fix edits until the repro fails reliably under `harness/loop.sh`.
- The library doubles as a regression suite (`repros/all.sh` on a cadence).
- For environment-dependent bugs, the repro script *includes its environment*: it invokes fault injection or trace replay (below) to create the condition, so the repro is self-contained.

## Network Capture (video-heavy links)

Full pcap of a video stream is infeasible; full pcap is also unnecessary.

- **Headers-only ring buffer, always on:**
  `tcpdump -s 128 -C <MB> -W <n> -w /var/log/pcap/ring` — snaplen ~96–128 bytes keeps Ethernet/IP/UDP/RTP headers and drops payload, cutting volume ~50–100×. RTP sequence numbers and timestamps survive, which is enough to detect loss, reordering, gaps, and jitter.
- **Stratify by plane:** control-plane traffic (signaling, ONVIF/RTSP, management) captured in full — it is low-volume and where protocol-usage bugs live; data-plane headers-only.
- **Agent-readable analysis:** batch tshark, not interactive Wireshark:
  `tshark -r ring.pcap -T fields -e frame.time_epoch -e rtp.seq -e rtp.timestamp ...`
  Small analysis scripts in `harness/analyze/` (sequence-gap finder, inter-packet-time histogram, malformed-packet filter) so the agent reads conclusions, not packets. Wireshark remains the human tool for novel protocol forensics; everything routine is scripted.
- On bug occurrence, `collect-diag.sh` snapshots the relevant ring window into the bundle.

## Fault Injection (synthesizing the trigger conditions)

Network degradation is synthesizable; a library of small scripts gives the agent environmental conditions as commands:

```bash
# faults/dropout.sh <duration_ms>     — momentary total loss: tc netem loss 100% for window,
#                                       or ip link down/up, or iptables drop
# faults/lossy.sh <pct> <jitter_ms>   — sustained radio-like impairment: netem loss/delay/reorder
# faults/partition.sh <duration_s>    — block specific peer(s)
# faults/sweep-dropout.sh             — parameter sweep: dropout duration × timing offset
#                                       relative to a protocol-cycle anchor; runs repro at each
#                                       point; reports the reproducing region
```

The sweep is the key tool for timing-dependent dropout bugs: "hard to replicate, seems to depend on timing" often means the bug only triggers in a small region of (dropout length × phase within the protocol cycle). Searching that space by hand is impractical; an agent running `sweep-dropout.sh` overnight can cover it. Once the reproducing region is found, the repro script pins those parameters and the bug is deterministic from then on.

Trace replay complements injection where the trigger is a specific input sequence rather than degradation: harvested header traces or control-plane captures replayed via tcpreplay (or a protocol-level player). Timing-sensitive interactions may not replay faithfully; injection sweeps are the fallback.

## Observability (instrument before the bug, not per-bug)

The failure mode to eliminate: a bug occurs, the logs turn out not to cover the failing region, and the occurrence is wasted. Instrumentation added after the fact, per-bug, is always one occurrence behind.

- **Structured events at every boundary and state transition:** socket errors, timeouts, reconnect attempts, buffer high-water marks, sequence-gap detections, state-machine transitions — one consistent, greppable taxonomy. These are the places environment bugs surface; instrument them once, systematically, instead of per-bug.
- **Counters over logs for timing pathologies:** periodically sampled queue depths, drop counts, gap counts, restart counts. A counter time series often localizes a timing bug faster than any log narrative.
- **Capture-first standing rule:** the response to any occurrence — lab or field — is harvest, then investigate. No occurrence is ever spent un-mined.

### Journal siphon (don't fight journald retention)

Deployed/test devices may have journald configured volatile or tiny (flash-sparing), rolling fast — and that configuration is not ours to change. The siphon makes it irrelevant: a sidecar service runs `journalctl -f -o json` with query-level filtering (`_SYSTEMD_UNIT=… PRIORITY=…`) and persists what matters under its own size cap. JSON output is newline-delimited with structured fields (`MESSAGE`, `PRIORITY`, `_SYSTEMD_UNIT`, `__REALTIME_TIMESTAMP`), so downstream analysis — human or agent — parses structure, never regexes prose.

- **Errors tier:** warnings-and-above from our units, persisted essentially forever. Filtered volume is tiny; flash cost negligible.
- **Follower-held window, not journald-held:** a key failure mode is that *the bug's own verbosity evicts its own cause* — the error storm accelerates rollover exactly when pre-storm context matters most. So the debug-level ring buffer lives in the follower's memory (a deque of the last 10–30 min of stream), not in journald. The follower saw every line once, in order; nothing journald rolls can evict what the follower already holds. Window length is sized to the worst observed causal lead time — it's RAM, so be generous.
- **Cursor sweep as backstop:** a timer using `journalctl --cursor-file` backfills gaplessly across follower crashes and reboots.

### Episodic capture (triggers)

Many bugs in this class announce themselves by log rate: quiet baseline, an eruption at failure, recovery. Capture is therefore episodic, with two triggers:

- **Rate anomaly (generic):** the follower monitors message rate per unit; a spike fires capture even with no known signature — this is what catches novel bugs.
- **Signature match (specific):** known patterns, kept as config data in `signatures.d/` — never code — so new patterns are dropped in (even scp'd mid-hunt) without rebuilding anything.

On trigger: immediately persist the in-memory pre-burst window (the cause, at quiet-period debug level), keep persisting the live stream through the storm, stop at rate-normalization plus margin, then invoke `collect-diag.sh` (pcap window, counters, flight-recorder dump) and notify. One bundle = cause + eruption + recovery.

### Runtime log-level control (no restarts)

Levels are switchable at runtime so verbosity can be raised mid-hunt without losing process state:

- **Rust:** `tracing-subscriber` reload layer wrapping the `EnvFilter`; per-module directives (`myapp::net::reconnect=trace`, rest at info). Trigger via SIGUSR1/2 handler — `systemctl kill -s SIGUSR1 myapp` over ssh is a one-liner an agent can run — or a small unix-socket control endpoint accepting filter strings.
- **Python:** `logging.getLogger("myapp.net").setLevel(...)` from the same signal handler.
- **Trace tier lives in-process:** trace volume exceeds what journald tolerates, so an in-memory `tracing` ring-buffer layer holds trace spans and dumps on the same triggers. Spans additionally carry causal context (request/stream/connection IDs) *into* error sites, so the error record names its own lineage — less archaeology per occurrence, independent of log volume.

## Stack Policy (Jetson / systemd / Rust + Python)

The target is a JetPack-based Jetson running systemd; application code is Rust and Python. The two languages get different policies because their failure modes differ.

### Python: the device is the only runtime

JetPack pins the Python interpreter and the entire CUDA/cuDNN/TensorRT stack to the L4T release; GPU wheels are NVIDIA Jetson builds; much of PyPI lacks aarch64 wheels. A development laptop cannot replicate this environment, so no attempt is made to: **Python executes only on-device.** Editing happens locally; execution happens through `harness/run.sh`.

- `uv` with a committed lockfile; `uv sync` on-device is a deploy step, not a troubleshooting session. Interpreter version pinned to JetPack's.
- GPU-stack packages (torch, TensorRT bindings) pinned to the NVIDIA Jetson builds for the installed L4T release; recorded in DEVICE.md.
- For environment reproducibility across units and across time, the GPU layer can run from jetson-containers images — not runnable on the laptop, but that is not the goal; identical environments across *devices* is.
- Host-side Python is limited to logic with no GPU/hardware imports, and only where it earns its keep; anything ambiguous runs on-device.

### Rust: one artifact, properly installed

Rust code is cross-compiled to aarch64 and shipped as a **Debian package** (`cargo-deb`), installed with `dpkg -i`, with the systemd unit(s) in the package. No loose binaries over scp: the artifact exercised during debugging is byte-identical to the production install — same paths, same unit, same permissions — so there is no dev-vs-prod difference to chase. The package build is itself a harness step, so the agent runs the full build→package→install→restart cycle unattended.

The verification ladder, cheapest tier first:

1. `cargo check` / `clippy` on the host — instant, no device. The agent's inner loop lives here; type-level errors never reach a deploy cycle.
2. `cargo test` on the host — unit/integration tests for everything hardware-independent (protocol logic, state machines, parsers).
3. On-device repro via `harness/loop.sh` — the only tier that costs a deploy, reserved for environment- and hardware-dependent behavior.

Tiers 1–2 absorb most defects before the device is involved, which is why Rust debugging should need far fewer deploy cycles than Python, whose only runtime is the device.

### Migration seam

Where Python code is a recurring defect source, module-by-module migration to Rust is preferred over rewriting wholesale. The seam: DeepStream elements are GStreamer plugins, and `gstreamer-rs` is mature — Rust owns pipeline construction, bus handling, pad probes, and all orchestration/protocol/recovery logic, while NVIDIA's elements do GPU work inside the pipeline. Ports are well-specified agent tasks: behavior is defined by the existing module, and the repro library serves as the acceptance suite for each ported piece.

### Diagnostics packaging: split .debs

Diagnostics must not enlarge the production attack surface, so two packages from one source tree:

- **`myapp.deb`** — production, lean. No debug tooling.
- **`myapp-diag.deb`** — the siphon unit, episodic-capture watcher, fault-injection scripts, analysis helpers. Installed only on dev and in-test devices — exactly where overnight-test log loss lives — and never on deployed units. Standard Debian companion-package practice.

The diag package is generic infrastructure and rarely changes; the part that changes per-bug (watcher signatures) is config data in `signatures.d/`, deliberately outside the package. The siphon unit carries `Restart=always`, ordering after journald, and resource caps (`MemoryMax=`, IO weight) so diagnostics cannot harm the product under test on a shared Jetson.

Optionally, the errors-only persistent tail may graduate into the production package as a *field-diagnosability feature* (post-mortems on deployed units). If shipped, the unit is its own security review: `DynamicUser=yes`, `NoNewPrivileges=yes`, `ProtectSystem=strict` with a single `ReadWritePaths=`, no network address families, journal read access only — twenty declarative lines demonstrating the process can do nothing else.

## Agent Integration

- **`DEVICE.md` in the repo** (template below): the agent's operating map for the target.
- **Permissions:** allowlist the `harness/`, `faults/`, and `repros/` commands so the loop runs unattended; raw arbitrary ssh stays gated.
- **Two loop shapes:**
  - *Reproducible (native, injected, or replayed):* hypothesis → edit → `harness/loop.sh repro` → analyze → iterate. Standard gates apply: failing repro before any fix; attempt budget (2–3 failures → write down ruled-out hypotheses → fresh session with the brief); diff minimization after green.
  - *Instrument-and-wait (irreducible environment dependence):* hypothesis → add targeted instrumentation that will confirm or kill it → deploy → wait for watcher-harvested occurrence (or physically trigger) → analyze bundle → narrow. Wall-clock per cycle is long, so every deployed instrumentation round must be hypothesis-driven, never shotgun logging — there may be only one or two occurrences per day.
- **Human touchpoints:** physically triggering conditions that cannot be injected, judging fixes, and novel protocol forensics. Everything else is the agent's.

## Appendix: DEVICE.md template

```markdown
# DEVICE.md — {target name}

## Access
- Host/IP, user, ssh config alias; ControlMaster settings
- VS Code remote notes if relevant

## Harness commands
- One line each: what it does, expected duration, artifact location, exit-code meaning

## Services & layout
- Service names, restart commands, config paths, log paths, scratch dirs safe to clear

## Constraints & safety
- Commands that must NOT be run (e.g., anything touching the radio config / bricking risks)
- Disk/CPU/memory limits relevant to capture and logging
- Hard timeout values per command class

## Known quirks
- Slow-boot behaviors, clock drift, flaky interfaces, anything that misleads diagnosis

## Environment notes
- Network topology, peers, radio characteristics; which conditions are injectable
  (faults/ scripts) vs. physical-only
```
