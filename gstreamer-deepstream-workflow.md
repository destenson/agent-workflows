# GStreamer / DeepStream Workflow

A workflow for agent-assisted development and debugging of GStreamer-based video applications: a Python application driving pipelines that mix NVIDIA DeepStream elements with custom Rust elements (gstreamer-rs, maintained as a fork of gst-plugins-rs), deployed on a Jetson. Companion to `embedded-target-workflow.md`, whose harness, capture, and stack policies all apply; this document covers what GStreamer and DeepStream add to that loop.

The motivating bug class: a custom `rtspsrc2` fork with agent-built reconnection logic that worked for months, then exposed failure modes papered over with an application-level Python workaround. The workflow's job is to make that class of bug — and GStreamer integration bugs generally — debuggable by an agent without a human's accumulated GStreamer instincts in the loop.

## Principles

1. **Silent failure is the default failure mode.** A C/Rust program crashes; a GStreamer pipeline *stalls*. No error on the bus, no buffers at the sink, threads parked in `gst_pad_push`. The workflow's first investment is making stalls loud: flow counters and watchdogs at every boundary, so "no data" becomes a detected, timestamped, bundle-triggering event instead of a discovered-hours-later one.
2. **The running graph is ground truth, not the code.** Pipelines assemble dynamically — pads appear, caps negotiate, autopluggers choose elements. The code says what was *requested*; only a dot dump says what was *built*. Diagnosis starts from the graph dump, and a healthy-vs-failed graph diff localizes most structural bugs in one step.
3. **Elements are black boxes observed at pads.** NVIDIA's elements are closed-source and even open elements are debugged faster by observing their pad contracts (caps, buffer flow, events, timestamps) than by reading their internals. Instrument *between* elements, uniformly. The exception is our own fork — the one box we can open — which is exactly why recovery logic belongs inside it (see Fork Policy).
4. **Most pipeline bugs don't need the Jetson.** RTSP protocol logic, reconnection state machines, caps handling — all reproduce on a host against a local test server. The triage ladder pushes every bug to the cheapest tier that reproduces it; the device is reserved for NVMM-, GPU-, and environment-dependent behavior.
5. **An app-level workaround is a falsified element contract.** Every watchdog-and-restart added in Python is a standing assertion that an element fails to honor its contract. Workarounds are legitimate mitigations, but each one gets a LESSONS.md entry, a repro, and a migration path that moves the behavior down into the element. Crutches are tracked debt, never silent permanent fixtures.

## Triage Ladder

Per-bug, the first question is which tier reproduces it. Each tier is ~an order of magnitude cheaper per iteration than the next; the agent works at the lowest reproducing tier and only ascends to confirm.

1. **Host, plugin crate tests.** Pure logic in the fork — state machines, protocol parsing, retry policy — under `cargo test`, using gstreamer-rs's harness/test support for pad-level element exercise where useful. The embedded doc's verification-ladder tiers 1–2.
2. **Host, full pipeline vs. local fault server.** The plugin loaded into a host pipeline against the scriptable RTSP server (below). This is where the reconnection bug class lives. Caveat recorded once and rechecked per-bug: host GStreamer version ≠ device version; a host repro is presumptive, a host *non*-repro under version skew proves nothing.
3. **Device, minimal pipeline.** Same fault server, reached over the real network path, pipeline cut down to source + parser + fakesink — no DeepStream. Isolates environment- and version-dependent behavior from GPU-stack behavior.
4. **Device, full DeepStream app.** Only for bugs that need NVMM, inference load, or the actual application topology. Iterations here run through `harness/loop.sh`.

## Harness Additions

Extending the `harness/` inventory from the embedded doc:

```bash
# harness/graph-dump.sh [name]   — signal the app to emit GST_DEBUG_BIN_TO_DOT_FILE dumps
#                                  (control endpoint or SIGUSR2), pull the .dot files back.
#                                  Dot is text: agents grep it, no rendering step needed.
# harness/flow-report.sh         — pull per-probe-point buffer/byte/timestamp counters from
#                                  the running app (see Observability); report rates and the
#                                  last-buffer age per point — the stall localizer.
# harness/gst-log.sh <spec>      — set GST_DEBUG categories at runtime via the app's control
#                                  endpoint (e.g. "rtspsrc2:7,rtpjitterbuffer:6"), no restart.
# harness/plugin-check.sh        — assert the device (or host) loads OUR .so: gst-inspect-1.0
#                                  on the element must report the git-stamped version and the
#                                  expected plugin path. Run by deploy.sh and loop.sh; a stale
#                                  or shadowed plugin fails the run before any repro executes.
# harness/pipeline-run.sh <desc> — run a gst-launch-1.0 description (or a named minimal Python
#                                  runner for cases needing dynamic pads/signals) with hard
#                                  timeout, GST_DEBUG capture, and dot dump on exit/stall.
```

Repro scripts (`repros/issue-N.sh`) follow the embedded doc's rules and additionally name their tier, so the regression suite runs host-tier repros on every change and device-tier repros on the device cadence.

## The RTSP Fault Server

The bottled environment for the source-bug class. A small server built on gst-rtsp-server (Rust or Python bindings — same library underneath) whose behavior is scriptable per-session, exposing protocol-level faults as commands alongside the embedded doc's packet-level `faults/` scripts:

```bash
# faults/rtsp-kill.sh <when>        — drop the TCP connection mid-PLAY / after SETUP / during DESCRIBE
# faults/rtsp-stall.sh <stage>      — accept the request, never respond (client-timeout paths)
# faults/rtsp-silent.sh             — complete the handshake, never send RTP (connected-but-dead)
# faults/rtsp-no-rtcp.sh            — send RTP but stop RTCP sender reports (keepalive/timeout paths)
# faults/rtsp-reject-reconnect.sh <n|duration> — refuse reconnection attempts, then accept
# faults/rtsp-new-sdp.sh            — accept reconnect but present changed SDP/caps (the rebuilt-
#                                     transport-stale-downstream trap)
# faults/rtsp-half-close.sh         — close one direction of the TCP connection
```

Protocol faults and netem packet faults compose: the matrix (server fault × network impairment × timing offset) is sweepable exactly like the embedded doc's dropout sweep, and reconnection-state-machine races are precisely the bugs that live in small regions of that space. Real servers (MediaMTX, actual cameras) are the validation tier, not the iteration tier — the fault server is for finding and pinning the bug, the real camera for confirming the fix.

A reconnection-specific repro idiom: loop N disconnect/reconnect cycles and assert *invariants across cycles* — buffer flow resumes within deadline, pad/element/fd counts return to baseline (leak per cycle is the classic rebuild bug), no duplicate internal tasks. One cycle passing means little; cycle 40 leaking means a lot.

## GStreamer Observability

The embedded doc's observability stack (structured events, counters, episodic capture, runtime log control) applied to GStreamer's native facilities:

- **Flow accounting at every boundary.** Pad probes at each inter-element link of interest, each maintaining buffer count, byte count, and last-buffer timestamp. These are the counters the embedded doc samples; `flow-report.sh` turns "the pipeline stalled" into "buffers stopped at the `rtpjitterbuffer` → `depay` link 43s ago while upstream kept flowing." The `watchdog` element (gst-plugins-bad) provides the same in-pipeline where probes are awkward: it posts a bus error after N ms without a buffer, converting silent stalls into bus events.
- **Bus messages are the event taxonomy.** ERROR/WARNING/INFO, state-changes, QoS, element-specific messages — all already structured. The app's bus handler logs them via the structured-event pipeline (journal siphon picks them up) rather than ad-hoc printing. Note the cascade trap, recorded once in PIPELINE.md: the element *posting* the error is frequently downstream of the element *causing* it; flow counters break the tie.
- **GST_DEBUG, ring-buffered.** Category levels (`rtspsrc2:7,rtpjitterbuffer:6,GST_CAPS:5,default:3`) are the per-module trace tier, and at trace level the volume exceeds what journald tolerates — same problem, same solution as the embedded doc: GStreamer's built-in ring-buffer logger holds the recent window in memory and dumps on the episodic-capture triggers. Runtime threshold changes ride the existing control endpoint, so verbosity rises mid-hunt without restarting the process (and without destroying the bug's state).
- **Dot dumps on trigger.** `GST_DEBUG_DUMP_DOT_DIR` set in the unit environment; the app dumps on state changes, on bus errors, on watchdog fire, and on demand via `graph-dump.sh`. The dump carries negotiated caps per link and per-element states — caps-negotiation failures and stuck async state changes are read directly off it. `collect-diag.sh` includes the dot files in every bundle; the healthy-baseline dump is committed to the repo for diffing.
- **RTP-layer counters.** `rtpjitterbuffer` and `rtpsession` expose stats (pushed/lost/late counts, jitter) as properties; sampled alongside the flow probes, they distinguish "network stopped delivering" from "element stopped processing" — the first fork in any silent-stall diagnosis.
- **Tracer runs as a tool, not a default.** `GST_TRACERS=leaks` over the N-reconnect-cycles repro is the refcount-leak detector (run with stack traces when it fires); `latency`/`stats` tracers answer timing questions. Tracers cost enough to be per-run choices in `pipeline-run.sh`, not always-on state. Available tracers depend on the JetPack-pinned GStreamer version — inventory recorded in DEVICE.md.

## Pipeline Reduction

The GStreamer-specific minimization procedure, agent-executable because every step is a concrete edit with a binary outcome:

1. Substitute the sink chain with `fakesink` (try `sync=true` first — `sync=false` changes timing semantics).
2. Substitute the inference/GPU branch with `identity` or cut it at a `tee`.
3. Substitute the source with `videotestsrc` (`is-live=true`) — if the bug survives, it is not a source bug; if it vanishes, the source layer is implicated.
4. Bisect remaining elements toward the minimal failing description, preferring `gst-launch-1.0`-expressible pipelines; bugs needing dynamic pads or signal wiring get a minimal Python runner instead.

Two standing cautions in PIPELINE.md: a bug that *vanishes* under substitution is evidence of a timing/clock dependence, not absence of a bug — note what the substitution changed (sync behavior, live-ness, allocation) before moving on. And queues are scheduling boundaries: removing one changes threading, so an appearing/vanishing bug under queue changes points at a streaming-thread interaction, frequently a real deadlock with shuffled timing. Thread dumps (`backtrace.sh` against the live pid; py-spy for the Python layers) are the deadlock tool — a stall plus a thread parked in `gst_pad_push` or a state-change function is diagnostic on its own.

## DeepStream Specifics

- **NVMM payloads are unreadable in place.** Buffers in `memory:NVMM` caps live in device memory; payload inspection requires an `nvvideoconvert` hop to system memory, expensive enough to perturb what's being measured. Keep it behind a normally-closed `valve` on a `tee` for the rare case it's needed. The embedded doc's "headers tell the story" holds: flow counters, PTS/DTS, caps, and NvDs metadata carry nearly all diagnostic value; payload almost none.
- **Buffer-pool starvation is the DeepStream-specific stall.** NVMM buffers come from fixed-size pools; a downstream element holding buffers starves upstream, which presents as the *source* stalling — flow counters that show upstream parked while downstream is idle should prompt pool-size and buffer-lifetime questions before source-bug questions. This trap rates a high-trap LESSONS.md entry the first time it bites.
- **Version pinning, one layer deeper.** JetPack pins L4T pins GStreamer pins DeepStream; nv-element behavior changes across DeepStream releases (mux semantics most notoriously). DEVICE.md records the full chain — JetPack/L4T, GStreamer, DeepStream versions, and which nv elements the app uses — because an agent reasoning from upstream GStreamer docs of the wrong minor version produces plausible nonsense.
- **Isolation favors the source layer.** Since nv elements can't be opened, bugs are attributed by exclusion: tier-3 minimal pipelines (no DeepStream) plus flow counters around each nv element. The practical rule: prove a bug *needs* the DeepStream branch before debugging at tier 4 — most of the rtspsrc-class bugs never do.

## Fork Policy (gst-plugins-rs)

The fork is the one element whose internals are ours, which gives it two special roles: it is where recovery logic belongs, and it is the most likely home of our bugs.

- **Build the crate, not the tree.** Only the workspace member containing our element is built and shipped. Cross-compilation follows the embedded doc's Rust policy (aarch64 .deb via the harness), with the gst-plugins-rs wrinkle: the sys crates resolve GStreamer through pkg-config, so cross builds need a sysroot carrying the device's GStreamer dev packages. The gstreamer-rs version feature flags (`v1_16`/`v1_20`/…) must not exceed the device's GStreamer version — set once from DEVICE.md, enforced by the build script.
- **Stamp and verify.** The plugin version string carries `git describe` (injected at build time); `plugin-check.sh` asserts it after every deploy and before every repro. The failure this kills — hours spent debugging a stale or shadowed .so — is common enough in GStreamer work to justify the gate: `GST_PLUGIN_PATH` ordering, a distro-shipped copy of the same element, and the registry cache (`~/.cache/gstreamer-1.0/`) are three independent ways to run code other than what was just built.
- **Upstream is a debugging resource.** Before any fork-element bug hunt: check upstream gst-plugins-rs log/MRs for the element — the bug may be fixed, or upstream may have grown an equivalent of a forked feature, making rebase-and-drop cheaper than fix-and-carry. Periodic rebase keeps that option open; fixes with no fork-specific coupling are upstreamed, shrinking the fork. The fork's divergence from upstream is itself tracked (a short FORK.md or DECISIONS.md entries: what was added, why, upstream status of each piece).
- **Recovery logic migrates down.** The standing direction from Principle 5: app-level Python workarounds are mitigations with tracked debt; the proper fix lives in the element, where reconnection owns the transport, the RTP session, *and* the timers/keepalives — app-level restarts can only rebuild the pipeline around a black box. Each workaround's migration is a well-specified agent task: the workaround's trigger condition defines the repro, the workaround's behavior defines the acceptance criterion, and the repro library keeps the workaround's scenario covered after the crutch is removed.

## Agent Integration

- **`PIPELINE.md` in the app repo** (template below) joins DEVICE.md as standing context: the agent's map of the graph, its invariants, and its known traps.
- **Loop shapes** follow the embedded doc, with the tier question prepended: *(0) which tier reproduces this?* → then either the reproducible loop (hypothesis → edit → tier-appropriate repro → analyze) or instrument-and-wait for field-only occurrences, with the GStreamer instrumentation (probes, ring-buffered GST_DEBUG, dot-on-trigger) as the deployed sensors.
- **Permissions:** the fault server controls and `pipeline-run.sh` join the harness allowlist so host-tier iteration runs fully unattended; host-tier loops have no deploy step and should converge in minutes per hypothesis.
- **Human touchpoints** shrink to: judging fixes, real-camera validation, and novel forensics (a genuinely unknown protocol behavior on the wire). Reconnection-matrix sweeps, leak hunts over N cycles, and pipeline bisection are all agent-shaped work — long, mechanical, evidence-producing.

## Appendix: PIPELINE.md template

```markdown
# PIPELINE.md — {app name}

## Topology
- Canonical pipeline description (gst-launch-ish text) and/or committed healthy dot dump
- Dynamic behavior: which pads appear when, what signals wire what

## Elements
- Per element: ours / NVIDIA / upstream-GStreamer; version source; known quirks
- For fork elements: divergence summary, upstream status

## Invariants (healthy state)
- Expected buffer rates / caps at each probed link
- Expected steady-state counts: pads, threads, fds (the leak baselines)
- Reconnect contract: max time-to-flow after server return, post-cycle baselines

## Probe points & controls
- Where flow probes live; control endpoint commands (log levels, dot dump, counters)

## Known traps
- Cascade pairs (element that posts the error vs. element that causes it)
- Timing-sensitive regions (what vanishes under fakesink/queue substitution and why)
- Pool-starvation signatures and other high-trap LESSONS.md pointers
```
