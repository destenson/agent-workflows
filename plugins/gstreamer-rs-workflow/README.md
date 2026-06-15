# gstreamer-rs-workflow

A Claude Code / Codex plugin implementing [`gstreamer-deepstream-workflow.md`](../../gstreamer-deepstream-workflow.md): the debugging instincts for GStreamer/DeepStream video pipelines with a forked `gstreamer-rs` element (`rtspsrc2`) on Jetson, plus the project scaffolding the workflow depends on.

It extends the base `agentic-workflow` (spec discipline, journaling, distillation gate) and the embedded-target workflow (the `harness/` loop, log siphon, Rust/Python stack policy). Install those for the full loop; this plugin adds only what GStreamer and DeepStream require.

## What it does

**Skills** (invoke when relevant):
- `gst-failure-triage` — the entry point: classify a failure by symptom (frozen video, bus ERROR, not-negotiated, hung state change, leak-after-N-reconnects, timing/QoS, teardown crash) and take the right first move.
- `gst-pipeline-reduction` — shrink a failing pipeline to a minimal repro by concrete substitutions with binary outcomes.
- `gst-lifetime-review` — diagnose/review object-lifetime and threading bugs across the Python app and the Rust element; doubles as the review checklist for the forked element.
- `gst-fork-triage` — fork policy: check upstream first, verify the running binary is ours, decide whether recovery logic moves from the Python workaround down into the element.
- `gst-reconnect-repro` — the RTSP fault server, assert-across-cycles invariants, and timing sweeps for reconnection bugs.

**Scaffolder skills** (manual-only — invoke explicitly; they write into the project):
- `pipeline-md-init` — scaffold `PIPELINE.md` (the graph map, healthy-state numbers, known traps) in the application repo.
- `gst-harness-init` — copy the harness and RTSP fault-server **contract stubs** into the project's `harness/` and `faults/`. The stubs document each script's arguments, exit codes, and artifacts, and exit non-zero with "TODO: implement" until filled in per project (they can't be generic — they talk to the app's control endpoint and the device's GStreamer version).

**Optional hook** (`PreToolUse`, off by default):
- `fork-lifetime-reminder.sh` surfaces the task/object-lifetime checklist when a change targets the forked element. It is **explicit, not heuristic**: it does nothing unless `GST_FORK_ELEMENT_PATH` is set to the element's source directory. Set it in the project's `.claude/settings.json` env block to enable. Advisory only; never blocks. The reminder goes to stderr — if your Claude Code version doesn't surface PreToolUse stderr into the model's context, invoke the `gst-lifetime-review` skill manually instead.

## Install

### Claude Code

```
/plugin marketplace add destenson/agent-workflows
/plugin install gstreamer-rs-workflow@agent-workflows
```

Then, in the application repo:

```
/gstreamer-rs-workflow:pipeline-md-init
/gstreamer-rs-workflow:gst-harness-init       # then implement the copied stubs per project
```

### Codex

```
/plugins marketplace add ./.agents/plugins/marketplace.json
/plugins install gstreamer-rs-workflow
```

Then, in the application repo, invoke the same scaffolders as `@pipeline-md-init` and `@gst-harness-init`. See [COMPATIBILITY.md](../../COMPATIBILITY.md) for how the dual-harness support works.

To enable the optional fork hook, add to the project's `.claude/settings.json`:

```json
{ "env": { "GST_FORK_ELEMENT_PATH": "path/to/gst-plugins-rs/net/rtsp" } }
```

## Requirements

- `jq` and `bash` on PATH (the hook script parses hook JSON).
- The harness/fault stubs assume the embedded-workflow harness exists (`build/deploy/run/collect-diag/device-reset/backtrace/loop`); these are the GStreamer-specific additions to it.

## Scope notes

- The harness and fault scripts ship as **stubs, not implementations** — the workflow doc calls them "contracts to implement per project," and they can't be otherwise: they depend on the app's control endpoint and the device's pinned GStreamer/DeepStream versions.
- `DEVICE.md` (the embedded workflow's target map) is referenced throughout but scaffolded by the embedded workflow, not here.
