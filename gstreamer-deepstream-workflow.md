# GStreamer / DeepStream Workflow

A workflow for agent-assisted development and debugging of GStreamer-based video applications. The stack: a Python application that builds and runs pipelines mixing NVIDIA DeepStream elements with custom Rust elements (written with gstreamer-rs, maintained as a fork of gst-plugins-rs), deployed on a Jetson. Companion to `embedded-target-workflow.md` — its harness, network capture, log siphon, and Rust/Python stack policies all apply here. This document covers only what GStreamer and DeepStream add.

The motivating case: a forked `rtspsrc2` element with added reconnection logic that worked for months and then failed in ways that are currently worked around at the application level in Python. But the goal is broader than one bug — GStreamer debugging normally depends on accumulated instinct (where to look, which tool answers which question, which symptoms mislead). This document writes those instincts down so an agent can debug new GStreamer problems methodically, not just the ones already catalogued.

## What makes GStreamer hard to debug

These are the properties of the framework that shape the tooling. None of them are exotic; together they explain why ad-hoc debugging in GStreamer goes slowly.

1. **The pipeline is assembled at runtime, so the code doesn't show you the pipeline.** Pads (the connection points between elements) can appear mid-stream, caps (the negotiated data formats on each link) are settled dynamically, and helper elements like `decodebin` choose and insert elements on the fly. The source code shows what was requested; only a dump of the live graph shows what was actually built and how it was connected. GStreamer can write that dump on demand (a Graphviz `.dot` file — see Observability), and diagnosis should start from it rather than from the code.
2. **Errors usually surface away from their cause.** Most failures are "loud": some element posts an ERROR message on the pipeline's bus (the message channel from elements to the application) and you have a starting point. But the element that *posts* the error is often just the first one to trip over a problem created upstream — a sink reporting a timestamp problem caused by the source, a decoder reporting corrupt data caused by packet loss. The error message tells you where the damage was noticed, not where it was done. Per-link flow statistics (below) are how you walk back from the reporter to the cause.
3. **Some failures are silent.** Less common than bus errors, but disproportionately expensive: data simply stops flowing, with no error posted — a thread blocks, a source quietly stops producing, a downstream element stops consuming. Nothing announces it; you discover it by noticing the video froze. Since these cost the most wall-clock time per incident, it is worth instrumenting specifically for them: per-link flow counters and watchdog timeouts that convert "no data" into a detectable, timestamped event.
4. **Elements are mostly observed, not opened.** NVIDIA's DeepStream elements are closed-source, and even for open elements it is usually faster to diagnose by watching their boundaries — what buffers, caps, and events go in and out of each pad — than by reading their internals. The one exception is our own forked element, whose internals we control; that is both where our bugs are most likely to live and where fixes belong (see Fork Policy).
5. **Pipelines are multi-threaded in non-obvious ways.** Each source and each `queue` element typically spawns a streaming thread, and some operations (notably state changes) are not safe to perform from inside one. The resulting deadlocks present as silent stalls. A thread dump of the stuck process is the direct tool: a thread parked in `gst_pad_push` or inside a state-change function names the suspect immediately.
6. **Object lifetimes are managed across two language runtimes and many threads.** GStreamer objects are reference-counted (GObject), and references to the same element are held simultaneously by the pipeline, by Python code (PyGObject wrappers, possibly from several Python threads), and — for our fork — by Rust tasks the element spawned internally. An object's real lifetime is the union of all of these, so "I tore down the pipeline" does not mean the objects died: a surviving reference in a Python closure or a still-running reconnect task keeps them alive, and a reference dropped too early leaves a thread operating on a dying object. This class of bug presents as leaks, shutdown hangs, or crashes during reconnection, and it gets its own section below.
7. **Most of the logic doesn't need the target hardware.** RTSP protocol handling, reconnection state machines, caps handling — all of it runs the same on a development host as on the Jetson. Only behavior involving NVIDIA's elements, GPU memory, or the real network environment actually requires the device. This is the single biggest lever for iteration speed and the basis of the triage ladder below.

## Recognizing the failure class

The first diagnostic step for any new problem is classification by symptom. Each class has a different first move; applying the wrong class's procedure wastes the iteration.

| Symptom | Likely class | First move |
|---|---|---|
| ERROR message on the bus | Loud failure — but the poster may not be the cause | Read the error, then check flow counters *upstream* of the posting element before trusting it |
| Video frozen / no output, no error posted | Silent stall | Flow report: find the last link where buffers still arrive — that brackets the stuck element. Then thread-dump it (deadlock?) and check RTP stats (did the network stop delivering, or did an element stop processing?) |
| Pipeline never starts; "not-negotiated" errors | Caps negotiation failure | Dot dump — it shows the negotiated caps on every link and where negotiation stopped |
| Pipeline stuck transitioning (e.g. never reaches PLAYING) | Hung state change | Query each element's state with a timeout; the dot dump also annotates per-element state, exposing the one that never completed |
| Works at first, degrades or fails after N reconnects/hours | Resource leak | Compare pad/thread/fd/memory counts against the healthy baseline; run the `leaks` tracer over a repeated-cycle repro |
| Output present but late, jerky, or wrong | Timing/QoS problem | QoS messages on the bus, latency tracer, timestamp inspection at probes |
| Crash or hang during teardown or reconnect; or pipeline torn down but threads/objects survive | Object lifetime / leaked task across threads | Thread dump of the stuck process; compare thread and object counts against baseline; see Threads and object lifetimes |
| Process crash | Ordinary native crash | The embedded doc's `backtrace.sh` path; nothing GStreamer-specific |

When a problem doesn't fit any row, fall back to the general procedure:

1. **Collect before theorizing.** One diagnostic bundle, gathered the moment the failure is observed: the bus message log, a dot dump of the failed pipeline, the flow report, and the recent debug-log window. `collect-diag.sh` produces all four; resist forming a hypothesis until they're in hand, because each one cheaply rules out whole classes.
2. **Compare against healthy.** Diff the failed dot dump against the committed healthy-baseline dump; diff the flow rates and resource counts against the recorded healthy values in PIPELINE.md. The discrepancy list is usually short and usually contains the lead.
3. **Localize, then minimize.** Use flow counters to name the suspect element or link, then use pipeline reduction (below) to shrink the repro around it.
4. **Then run the normal loop** — hypothesis, edit, repro, analyze — at the cheapest tier that reproduces (next section), under the embedded doc's standard gates (failing repro before any fix; attempt budget; record dead ends).

## Triage ladder

Per-bug, establish which tier reproduces it, and work at that tier. Each step down the ladder costs roughly an order of magnitude more per iteration.

1. **Host: plugin crate tests.** Logic inside the fork — state machines, protocol parsing, retry policy — exercised by `cargo test`, optionally using gstreamer's test-harness support to drive an element through its pads without a full pipeline.
2. **Host: real pipeline against a local fault server.** The plugin loaded into a pipeline on the development machine, talking to the scriptable RTSP server described below. This is where the reconnection bug class lives, and iteration here is seconds, not deploy cycles. One caveat to keep in view: the host's GStreamer version differs from the device's, so a host reproduction is strong evidence but a host *non*-reproduction doesn't clear the bug.
3. **Device: minimal pipeline.** The same fault server, reached over the real network path, with the pipeline cut down to source → parser → `fakesink` — no DeepStream elements. This isolates "needs the device/network environment" from "needs the GPU stack."
4. **Device: full application.** Only for bugs that genuinely require NVIDIA elements, GPU memory, inference load, or the full topology. Iterations run through `harness/loop.sh` as in the embedded doc.

## Harness additions

Additions to the `harness/` inventory from the embedded doc. As there, these are sketches — contracts to implement per project.

```bash
# harness/graph-dump.sh [tag]    — ask the running app to write dot files of its pipeline(s)
#                                  (via its control endpoint or a signal), then pull them back.
#                                  Dot files are plain text; an agent greps them directly.
# harness/flow-report.sh         — pull the per-link flow counters from the running app and
#                                  report: rate at each probe point, and seconds since the last
#                                  buffer at each point. This is the tool that turns "it froze"
#                                  into "buffers stopped at link X, 43s ago, while upstream flowed."
# harness/gst-log.sh <spec>      — change GST_DEBUG category levels in the running app without
#                                  a restart (e.g. "rtspsrc2:7,rtpjitterbuffer:6").
# harness/plugin-check.sh        — verify via gst-inspect-1.0 that the element resolves to OUR
#                                  freshly built .so (git-stamped version string, expected path).
#                                  Run after every deploy and before every repro.
# harness/pipeline-run.sh <desc> — run a pipeline from a gst-launch-1.0 description (or a named
#                                  minimal Python runner when dynamic pads/signals are needed),
#                                  with a hard timeout, GST_DEBUG capture, and a dot dump on
#                                  exit or stall.
```

Repro scripts follow the embedded doc's rules (`repros/issue-N.sh`, self-contained, exit 0/1) and additionally declare their tier, so host-tier repros run as a fast regression suite on every change and device-tier repros run on the device cadence.

## The RTSP fault server

For source/reconnection bugs, the triggering condition is server (mis)behavior, so the test environment is a server we control. gst-rtsp-server (usable from Rust or Python) makes it straightforward to build a small RTSP server whose failure behavior is scriptable per session. Each fault below exists because it exercises a specific path in the client that normal operation never touches:

```bash
# faults/rtsp-kill.sh <when>      — drop the TCP connection mid-PLAY / after SETUP / mid-DESCRIBE.
#                                   Exercises: detection of an abrupt disconnect at each protocol stage.
# faults/rtsp-stall.sh <stage>    — accept a request, never respond.
#                                   Exercises: client-side request timeouts (often missing or unbounded).
# faults/rtsp-silent.sh           — complete the handshake, never send any RTP.
#                                   Exercises: "connected but no data" detection — the state app-level
#                                   watchdogs usually exist to catch.
# faults/rtsp-no-rtcp.sh          — send RTP normally but stop RTCP sender reports.
#                                   Exercises: keepalive/liveness logic that keys off RTCP.
# faults/rtsp-reject.sh <n|secs>  — refuse reconnection attempts for a count/duration, then accept.
#                                   Exercises: retry backoff and give-up policy.
# faults/rtsp-new-sdp.sh          — accept the reconnect but present different SDP (codec/caps).
#                                   Exercises: whether reconnect handles a changed stream, or silently
#                                   feeds new data into a pipeline built for the old caps.
# faults/rtsp-half-close.sh       — close one direction of the TCP connection only.
#                                   Exercises: half-open connection handling (reads hang, writes "succeed").
```

These protocol-level faults compose with the embedded doc's packet-level `tc netem` faults, and the embedded doc's parameter-sweep technique applies directly: race conditions in a reconnection state machine typically only manifest when the fault lands in a narrow window relative to the protocol cycle, and a scripted sweep over (fault type × timing offset) searches that space mechanically — overnight, by an agent — where a human cannot.

One repro pattern deserves special mention for this bug class: **assert across cycles, not within one.** Run N disconnect/reconnect cycles and check invariants after each — data flowing again within a deadline, and pad/thread/fd counts back to their baseline. A reconnect that works once but leaks one pad per cycle is the classic rebuild bug, and it is invisible to any single-cycle test.

Real servers (MediaMTX, actual cameras) remain in the loop as the *validation* tier: the fault server is for finding and pinning a bug; the real camera confirms the fix holds against real behavior.

## Observability: the GStreamer toolbox

What each facility is, and which question it answers. These plug into the embedded doc's machinery (journal siphon, episodic capture, counter sampling) rather than replacing it.

- **Flow counters via pad probes.** A pad probe is a callback the application attaches to a pad, invoked for every buffer that crosses it. At each link worth watching, a probe maintains three numbers: buffer count, byte count, timestamp of the last buffer. Cheap enough to leave on permanently. Question answered: *where exactly did data stop, and when?* These counters are also what the embedded doc's periodic counter sampling picks up.
- **The `watchdog` element** (from gst-plugins-bad) can be dropped into a pipeline and posts a bus ERROR if no buffer passes it within a configurable timeout. Question answered: same as above, but as an in-pipeline tripwire that needs no application code — useful in minimal repros.
- **Bus messages, logged structurally.** Errors, warnings, state changes, QoS notifications, and element-specific messages all arrive on the bus already structured. The application's bus handler should emit them through the structured-event logging the embedded doc prescribes (so the journal siphon captures them), not print them ad hoc. Remember property 2 above when reading them: the poster is a suspect's neighbor, not necessarily the suspect.
- **GST_DEBUG logging, ring-buffered.** GStreamer's internal logging is organized into per-module categories with independent levels — `GST_DEBUG=rtspsrc2:7,rtpjitterbuffer:6,default:3` means "everything from our element, most things from the jitter buffer, warnings elsewhere." Two operational notes. Volume: at high levels this output is far too large for journald, which is the same problem the embedded doc solves with an in-memory ring buffer — GStreamer has that built in (`gst_debug_add_ring_buffer_logger` keeps the recent window in memory for dumping when an episodic-capture trigger fires). Runtime control: thresholds are changeable in a running process, which is what `gst-log.sh` exposes — verbosity can be raised mid-incident without restarting the process and destroying the state being debugged.
- **Pipeline graph dumps ("dot dumps").** With `GST_DEBUG_DUMP_DOT_DIR` set in the service's environment, the application can write a Graphviz description of a live pipeline at any moment (`GST_DEBUG_BIN_TO_DOT_FILE`). The dump contains the full topology, the negotiated caps on every link, and each element's current state — which is why it answers the caps-negotiation and stuck-state rows of the table directly. Dump on bus errors, on watchdog fire, and on demand; include the dumps in every diagnostic bundle; and commit one known-healthy dump to the repo so a failed graph can be diffed against it. The files are text — agents read them without rendering.
- **RTP-level statistics.** `rtpjitterbuffer` and `rtpsession` (inside the source's RTP handling) expose counters as properties: packets pushed, lost, late, plus jitter. Question answered: *did the network stop delivering, or did an element stop processing what was delivered?* — the first fork in every silent-stall investigation, and unanswerable from flow counters alone.
- **Tracers, per-run.** GStreamer tracers are opt-in instrumentation enabled by environment variable for a single run. The `leaks` tracer is the one to reach for on reconnect-cycle leaks (it reports objects alive at exit, with stack traces if asked); `latency` answers end-to-end timing questions. They cost enough overhead to be per-run tools in `pipeline-run.sh`, not standing configuration. Which tracers exist depends on the GStreamer version, which on the device is pinned by JetPack — record the inventory in DEVICE.md.

## Pipeline reduction

The standard way to shrink a failing pipeline to a minimal repro. Each step is a concrete substitution with a binary outcome, which makes the whole procedure agent-executable:

1. Replace the sink chain with `fakesink` (keep `sync=true` initially — `sync=false` also disables clock synchronization, which changes timing behavior).
2. Replace the GPU/inference branch with `identity`, or cut it off at a `tee`.
3. Replace the source with `videotestsrc is-live=true`. If the bug survives, the source layer is exonerated; if it vanishes, the source layer is implicated.
4. Keep bisecting elements until the description is minimal, preferring pipelines expressible as a `gst-launch-1.0` line; when the bug needs dynamic pads or signal wiring (as reconnection bugs do), use a minimal Python runner instead.

Two cautions, worth recording in PIPELINE.md the first time each one bites. First: a bug that *disappears* under substitution has not been ruled out — the substitution changed timing, threading, or buffer allocation, and the disappearance itself is evidence (usually of a timing dependence on whatever was changed). Note what the substitution altered before drawing conclusions. Second: `queue` elements are thread boundaries — adding or removing one changes which elements share a streaming thread. A bug that appears or vanishes with queue changes points at a thread interaction, and quite possibly a real deadlock whose timing got shuffled; that is the cue to take thread dumps rather than keep bisecting.

## DeepStream specifics

- **GPU-memory buffers can't be inspected in place.** DeepStream pipelines carry buffers in GPU device memory (caps marked `memory:NVMM`). Reading the actual image data from the CPU requires inserting `nvvideoconvert` to copy it to system memory — expensive enough to perturb the behavior under test. In practice this matters less than it sounds: flow counters, timestamps, caps, and DeepStream's attached metadata (`NvDsMeta`) answer nearly every diagnostic question without touching pixels. For the rare case that needs pixels, keep a `tee` + `valve` (normally closed) debug branch rather than improvising one mid-incident.
- **Buffer-pool starvation is the DeepStream-specific stall.** NVMM buffers come from fixed-size pools. If a downstream element holds buffers too long, the pool empties and *upstream* blocks waiting for a free buffer — so the symptom (source stopped producing) points at the opposite end of the pipeline from the cause. When flow counters show upstream parked while downstream sits idle, check pool sizes and buffer lifetimes before suspecting the source. This is the most misleading stall signature in the stack, which is exactly why it's written down here.
- **The version chain is long and pinned.** JetPack pins L4T, which pins the GStreamer version, which constrains the DeepStream version, and NVIDIA element behavior changes between DeepStream releases (the stream muxer most notoriously). DEVICE.md records the whole chain plus the list of NVIDIA elements in use, because reasoning from documentation for the wrong version produces confident, wrong conclusions — for humans and agents alike.
- **Attribute by exclusion.** Closed elements can't be opened, so bugs are assigned to the DeepStream layer only by elimination: if the tier-3 minimal pipeline (no NVIDIA elements) doesn't reproduce, and flow counters bracket the failure inside the DeepStream branch, then it's a DeepStream-layer problem — and the response is usually configuration, version, or workaround, not code. Prove a bug needs tier 4 before debugging at tier 4; most source-layer bugs never do.

## Threads and object lifetimes

The lifetime problem from property 6, in enough detail to act on. It has two halves — the Python application side and the Rust element side — and they produce confusingly similar symptoms (leaks per reconnect cycle, hangs at shutdown, crashes mid-reconnect), so the first job is telling them apart.

### Python side: references and callbacks

- **A Python reference is a strong reference.** Any element a Python variable, list, or closure still points to stays alive after the pipeline is set to NULL and discarded. Reconnect logic that rebuilds pipelines while old callbacks, probe handles, or element references linger in Python state accumulates live objects on the C side that Python's garbage collector has no urgency about. Worse, closures that capture pipeline objects can form reference cycles spanning the Python/GObject boundary, which collect late or not at all.
- **Callbacks arrive on GStreamer's threads, not yours.** Pad probes, `pad-added` handlers, and sync bus handlers run on whatever streaming thread fired them. The GIL makes the Python interpreter safe to enter from those threads; it does not make the *application's* state handling safe, and it does not make it legal to do heavy work or pipeline state changes from inside the callback — that is the deadlock class from property 5, reached from Python. The discipline: callbacks record and hand off (push to a queue, schedule on the main loop via `GLib.idle_add`) and return immediately; pipeline manipulation happens on one designated thread.
- **Multiple Python threads touching the same element** are safe for individual property reads/writes (GStreamer locks those internally) but not for compound sequences — check-then-act on pipeline state from two threads is a race regardless of the GIL.
- **Distinguishing Python-side from element-side leaks:** the `leaks` tracer reports C-level GStreamer objects alive at exit but not *who* keeps them alive. If the tracer shows leaked elements, check Python first — `gc` module inspection, or simply whether dropping the suspect Python references (and forcing a collection) releases them. Element-internal leaks survive that test; Python-side leaks don't. This check is cheap and should precede any hunt inside the element.

### Rust element side: tasks spawned for reconnection

This is the fork's known weak area, recorded here as standing knowledge: `rtspsrc2`'s reconnection and per-protocol handling spawn internal tasks, and managing object lifetimes across those tasks in a GStreamer-friendly way is where it has historically struggled. The rules the element must follow, which double as the review checklist for any change to it:

- **Tasks must hold weak references to the element.** In gstreamer-rs, cloning an element handle bumps a refcount. A spawned task that captures a strong clone keeps the element alive for as long as the task runs — so a task that never exits means an element that never disposes, which is one leak-per-reconnect-cycle mechanism. And if the element also stores the task's handle, the cycle is complete and nothing ever frees. The pattern: tasks capture a downgraded (weak) reference and upgrade it each time they need the element, treating a failed upgrade as their exit signal.
- **Teardown must stop and join every task it started.** The state change toward NULL is the element's contract point: when it returns, nothing the element spawned may still be running. A reconnect task that outlives teardown operates on a half-dead element — posting to a bus nobody drains, pushing buffers into deflowed pads — and produces exactly the "crash or hang during teardown" row of the table. Cancellation must also be *waited on*, not just signaled; a signaled-but-unjoined task is the same bug with a narrower window.
- **One generation of tasks at a time.** The reconnect race class: a disconnect fires, a new connection task starts while the old transport task is still draining, and two generations of tasks now touch shared session state. A generation counter or cancellation token per connection attempt — where each task checks it belongs to the current generation before acting — is the standard cure. The fault server's timing sweeps exist largely to flush out exactly this.
- **Don't hold the element's locks across blocking points.** Holding an internal mutex across a network await, a pad push, or a state-change call invites lock-order deadlocks with GStreamer's own streaming and state locks. Lock, copy what's needed, unlock, then block.

Each rule maps to an invariant the N-cycle reconnect repro checks mechanically: thread/task count returns to baseline after every cycle, element refcounts return to expected, and a pipeline shutdown completes within a deadline (a hang at NULL is almost always a task join that never finishes). Violations found in the field get LESSONS.md entries naming which rule was broken and how it presented, because the symptom-to-rule mapping is the part that's expensive to rediscover.

## Fork policy (gst-plugins-rs)

The forked element is the one component whose internals we control. Two consequences: it is the most likely home of our bugs, and it is where recovery behavior should ultimately live. Its known weak area is the task/lifetime discipline described in the previous section — when triaging a new bug in the element, the lifetime rules are the first checklist to apply, before suspecting protocol logic.

- **Build the one crate, not the tree.** Only the workspace member containing our element gets built and shipped. Cross-compilation follows the embedded doc's Rust policy (aarch64, packaged as a .deb, installed by the harness), with one gst-plugins-rs-specific requirement: the build resolves GStreamer through pkg-config, so cross builds need a sysroot containing the *device's* GStreamer development packages, and the gstreamer-rs version feature flags (`v1_16`, `v1_20`, …) must not exceed the device's GStreamer version — an element built against newer APIs can fail to load or misbehave subtly. Set once from DEVICE.md; enforce in the build script.
- **Stamp the build; verify before every run.** The plugin's version string carries `git describe`, injected at build time, and `plugin-check.sh` asserts it after deploy and before each repro. The failure this prevents — debugging an old binary while believing it's the new one — has three independent causes in GStreamer (search-path ordering via `GST_PLUGIN_PATH`, a distro-packaged copy of the same element shadowing ours, and the plugin registry cache at `~/.cache/gstreamer-1.0/` serving stale metadata), which is why it's a hard gate rather than a habit.
- **Check upstream before debugging.** The fork tracks upstream gst-plugins-rs, where `rtspsrc2` is under active development. Before any bug hunt in the forked element: check upstream's log and merge requests for the area. The bug may already be fixed, or upstream may have grown its own version of a forked feature — in which case rebasing onto it and dropping the fork's copy beats fixing and carrying ours. Keep a short record (FORK.md or DECISIONS.md entries) of what the fork adds, why, and each piece's upstream status; pieces with no fork-specific coupling get submitted upstream, shrinking what we maintain.
- **Move recovery logic down into the element, deliberately.** The current Python workaround is the situation this policy addresses. An application-level workaround is legitimate as a mitigation, but it is also evidence: it proves the element fails to honor its contract under some condition. The element is the right home for recovery because it owns the transport, the RTP session, and the timers — it can rebuild a connection in place, where the application can only tear down and rebuild the pipeline around a black box. So each workaround gets: a LESSONS.md entry (what condition triggers it, what it does), a repro derived from its trigger condition, and a migration task whose acceptance criterion is the workaround's own behavior — implemented in the element, verified by the repro, after which the Python crutch is removed and the repro stays in the regression suite.

## Agent integration

- **`PIPELINE.md` in the application repo** (template below) joins DEVICE.md as standing context: the map of the graph, its healthy-state numbers, and the traps already paid for.
- **Loop shapes** are the embedded doc's two, with one question prepended: *which tier reproduces this?* Reproducible bugs get the standard loop (hypothesis → edit → tier-appropriate repro → analyze) at the cheapest reproducing tier; field-only bugs get instrument-and-wait, with the GStreamer instrumentation above (probes, ring-buffered debug log, dot-on-trigger) as the deployed sensors.
- **Permissions:** the fault server controls and `pipeline-run.sh` join the harness allowlist, so host-tier iteration — which has no deploy step — runs fully unattended at minutes per hypothesis.
- **Human touchpoints:** judging fixes, validating against real cameras, and genuinely novel wire-level forensics. Sweeps over fault-timing matrices, N-cycle leak hunts, and pipeline bisection are long, mechanical, and evidence-producing — agent-shaped work.

## Appendix: PIPELINE.md template

```markdown
# PIPELINE.md — {app name}

## Topology
- Canonical pipeline description (gst-launch-style text) and/or a committed healthy dot dump
- Dynamic behavior: which pads appear when; what signals wire what

## Elements
- Per element: ours / NVIDIA / stock GStreamer; version source; known quirks
- For forked elements: what the fork adds, upstream status of each piece

## Healthy-state numbers
- Expected buffer rates and caps at each probed link
- Steady-state counts: pads, threads, fds (the baselines leak checks compare against)
- Reconnect contract: max time from server return to flowing data; post-cycle baselines

## Probe points & controls
- Where the flow probes sit; control endpoint commands (log levels, dot dump, counter pull)

## Known traps
- Error-cascade pairs seen so far (element that posted vs. element that caused)
- Timing sensitivities (what vanished under which substitution, and what that implied)
- Pool-starvation signatures and pointers to the relevant LESSONS.md entries
```
