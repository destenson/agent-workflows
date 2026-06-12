---
description: Scaffold PIPELINE.md (the pipeline's standing-context map) in the current application repo.
---

Create `PIPELINE.md` in the application repo root from the template at `${CLAUDE_PLUGIN_ROOT}/templates/PIPELINE.md`, but only if it does not already exist — if it does, leave it and report that it was skipped.

PIPELINE.md is standing context alongside DEVICE.md: the map of the graph, its healthy-state numbers (buffer rates, caps, steady-state pad/thread/fd counts, the reconnect contract), the probe points and control commands, and the traps already paid for (error-cascade pairs, timing sensitivities, pool-starvation signatures). Leave the template's placeholders in place — they get filled from a committed healthy dot dump and measured baselines, not guessed.
