---
name: negative-results
description: Document a negative result — a falsified hypothesis, a failed approach, or an inconclusive experiment. Use after a results memo or when an experiment is stopped early. The most underrecorded document type in the tree, and often the highest reuse value.
---

# Negative results

A negative result is any outcome where the hypothesis was not confirmed: the approach failed, the hypothesis was falsified, the experiment was inconclusive, or the effort was stopped before completion. These are not failures of the research — they are findings. They become failures only when they are not recorded.

Negative results are the most commonly dropped nodes in the R&D document tree. The consequence is that future teams repeat the same experiments, hit the same walls, and lose the same time. This document exists to prevent that.

## How to run it

1. Ask the user: what was the hypothesis or goal, and what happened? Get the specific outcome — not "it didn't work" but "metric X was Y instead of the expected Z" or "the approach failed because of condition C."

2. Ask: was this a clean falsification (the hypothesis was tested and disproved), an inconclusive result (the experiment could not produce a verdict), or an abandoned effort (stopped before completion for reasons other than the experimental result)? The type matters for how future readers will interpret and reuse this.

3. Ask: what is the mechanism, if known? Why did the approach fail? A negative result without a mechanism is less reusable — future teams know not to try X, but not why, which means they may try X under slightly different conditions and hit the same wall again.

4. Ask: what would need to be different for this approach to work? Even if the answer is "we don't know," that is worth recording. If there is a plausible path (more data, different architecture, different scope), name it — that becomes the input to a follow-on hypothesis.

5. Ask: are there any partial findings worth keeping? An experiment that failed its primary metric may still have produced useful measurements, validated a tool or pipeline, or revealed a property of the dataset. These should be recorded.

6. Draft the document. The framing must be neutral — a negative result is a finding, not a confession. Future readers are looking for information, not accountability.

## Template

See [negative-results-template.md](./negative-results-template.md).
