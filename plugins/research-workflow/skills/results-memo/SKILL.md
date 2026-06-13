---
name: results-memo
description: Draft a results memo — the eval report that synthesizes run logs and measurements into findings. Use after experiments are complete. Produces the document that justifies the decision memo.
---

# Results memo

A results memo synthesizes what was measured into what was learned. It is the `eval_report` node in the document tree — it `derives_from` run logs and datasets, and it `justifies` the decision memo that follows it.

The memo has one job: answer whether the experiment confirmed, falsified, or was inconclusive on the hypothesis stated in the experiment plan. Everything else is context for that answer.

**A results memo that does not reference the experiment plan's hypothesis and stopping rule is incomplete.** If the plan was not written before the experiment, surface that explicitly — it means the results cannot be cleanly interpreted as confirmation or falsification.

## How to run it

1. Ask the user: where is the experiment plan? Pull the hypothesis, primary metric, confirmation threshold, and stopping rule from it. If no plan exists, note this prominently in the memo — it affects how the results can be interpreted.

2. Ask: what did the runs actually produce? Walk through: the primary metric value(s), baseline comparisons, any ablation results. Get numbers, not impressions.

3. Ask: were there any surprises — results that were not predicted by the hypothesis, failures, or anomalies in the data? These are often the most important part of the memo and the most commonly omitted.

4. Ask: did anything deviate from the experiment plan? Changed metrics, different stopping condition, datasets swapped, baselines skipped? Deviations must be recorded and their effect on interpretability noted.

5. Draft the memo. The core finding must be a direct, declarative statement: the hypothesis was **confirmed**, **falsified**, or **inconclusive**, with the evidence that supports that verdict. Do not bury the finding in caveats.

6. Ask the user: what is the decision this feeds? The results memo should end by naming the options on the table for the decision memo — do not make the decision here, but make it easy to make.

## Template

See [results-memo-template.md](./results-memo-template.md).
