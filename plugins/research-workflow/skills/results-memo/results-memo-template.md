# Results Memo: <title>

> **Status:** draft | final
> **Author:** <name> · **Date:** <YYYY-MM-DD>
> **Derives from:** <run logs, datasets — link each>
> **Tests:** <link to experiment plan>
> **Justifies:** <link to decision memo — populated after>

## Verdict

> One sentence. The hypothesis was **confirmed** / **falsified** / **inconclusive**.
> State the primary metric value and how it compares to the confirmation threshold.

## Hypothesis and what was tested

Restate the hypothesis from the experiment plan. If the experiment deviated from the plan, note it here and explain the effect on interpretability.

Primary metric: <name>
Confirmation threshold: <from experiment plan>
Observed value: <measured result>

## Results

### Primary metric

| Run | Metric value | Notes |
|-----|-------------|-------|
| | | |

Baseline comparisons:

| Baseline | Baseline value | Delta | Interpretation |
|----------|---------------|-------|----------------|
| | | | |

### Ablations (if applicable)

| Ablation | Metric value | What it isolates | Interpretation |
|----------|-------------|------------------|----------------|
| | | | |

### Surprises and anomalies

Results that were not predicted, failures encountered, or anomalies in the data. These are not failures of the experiment — they are findings. Record them.

## Deviations from experiment plan

List every deviation: changed metrics, different stopping condition, datasets swapped, baselines not run. For each, explain the effect on how the results can be interpreted.

If there were no deviations, state that explicitly.

## Limitations

What this experiment cannot tell us. What would need to be true for the results to fail to generalize.

## Options for the decision memo

What the results make possible. This section does not make the decision — it names what is on the table.

- **Ship** — if applicable, what would be needed
- **Iterate** — what specific change and what hypothesis would the next experiment test
- **Kill** — what this result implies for the broader research direction
