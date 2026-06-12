---
name: gst-pipeline-reduction
description: Shrink a failing GStreamer pipeline to a minimal reproducer by concrete element substitutions with binary outcomes. Use after flow counters have bracketed the suspect element/link and you need a small, fast repro.
---

# Pipeline reduction

Shrink a failing pipeline to a minimal repro. Each step is a concrete substitution with a binary outcome, which is what makes it agent-executable:

1. Replace the sink chain with `fakesink` (keep `sync=true` initially — `sync=false` also disables clock synchronization, which changes timing behavior).
2. Replace the GPU/inference branch with `identity`, or cut it off at a `tee`.
3. Replace the source with `videotestsrc is-live=true`. If the bug survives, the source layer is exonerated; if it vanishes, the source layer is implicated.
4. Keep bisecting elements until minimal, preferring pipelines expressible as a `gst-launch-1.0` line. When the bug needs dynamic pads or signal wiring (as reconnection bugs do), use a minimal Python runner instead.

Two cautions — record each in PIPELINE.md's "known traps" the first time it bites:

- **A bug that disappears under substitution is not ruled out.** The substitution changed timing, threading, or buffer allocation; the disappearance is itself evidence, usually of a timing dependence on whatever changed. Note what the substitution altered before concluding.
- **`queue` elements are thread boundaries.** Adding/removing one changes which elements share a streaming thread. A bug that appears or vanishes with queue changes points at a thread interaction — possibly a real deadlock whose timing got shuffled. That's the cue to take thread dumps rather than keep bisecting.
