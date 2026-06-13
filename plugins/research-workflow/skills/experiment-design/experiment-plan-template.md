# Experiment Plan: <title>

> **Status:** draft | active | done | superseded
> **Author:** <name> · **Date:** <YYYY-MM-DD>
> **Tests:** <link to parent proposal and hypothesis>
> **Run logs:** <populated as runs are recorded>

## Hypothesis under test

Restate the hypothesis from the proposal exactly. Do not paraphrase — any drift here is a gap between what was approved and what was actually tested.

What observation would falsify it:

## Primary metric and confirmation threshold

Metric: <name and definition — be precise enough that two people would compute the same number>

Threshold: <the value or comparison that counts as confirmation, committed before running>

Secondary metrics (informational only, do not drive the stop/continue decision):

## Baselines

| Baseline | Description | Why it's the right comparison |
|----------|-------------|-------------------------------|
| <name> | <specific, runnable description with citation if applicable> | |

## Datasets / data sources

| Dataset | Source | Availability | Notes |
|---------|--------|--------------|-------|
| <name> | <location or citation> | public / internal / to be created | |

## Ablations

List planned ablations and what component each isolates. If no ablations are planned, state that explicitly and why.

## Stopping rule

The experiment is done when: <specific condition — a number of runs, a metric threshold, a deadline, or an explicit decision to stop early with reason recorded>.

Early stopping is allowed if: <conditions under which stopping before the rule is justified — e.g., metric is clearly above or below threshold before the planned number of runs>.

## Compute and resource estimate

Estimated cost, runtime, and any external dependencies (datasets, APIs, hardware) needed to execute this plan.

## Open questions

Unknowns that must be resolved before or during execution. Assign an owner for each.
