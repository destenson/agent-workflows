---
name: experiment-design
description: Draft an experiment plan — the methods protocol that connects a proposal's hypothesis to the run that will test it. Use after a research proposal is approved and before any experiments are run. Produces the document that run logs and eval reports derive from.
---

# Experiment design

An experiment plan is the contract between the hypothesis (what the proposal claimed to test) and the execution (what was actually run). Its purpose is to commit, in writing and before seeing any results, to: what you will measure, what counts as confirmation or falsification, and when you will stop. Without this document, results are post-hoc rationalized rather than pre-committed.

This is the `experiment_plan` node in the document tree. It `tests` the hypothesis in the parent proposal and `spawns` run logs.

## How to run it

1. Ask the user: which proposal does this experiment address? Retrieve or confirm the hypothesis and falsification criterion from that proposal. Do not proceed if the hypothesis is not stated — that is a problem to resolve in the proposal, not here.

2. Ask: what is the primary metric, and what threshold on that metric counts as confirmation? Push for a number, not a direction. "Better than baseline" is not a stopping rule.

3. Ask: what are the baselines? A baseline is a specific, runnable comparison — a prior version, a known algorithm, a trivial bound. "State of the art" without a citation is not a baseline.

4. Ask: what datasets or data sources will be used? For each, confirm: is it publicly available, internally available, or does it need to be created? Data availability is a dependency, not a detail.

5. Ask: what ablations are planned, if any? An ablation removes or isolates one component to test its contribution. Not all experiments need ablations, but if the proposed approach has multiple parts, it should be clear which part is expected to do the work.

6. Ask: what is the stopping rule? The stopping rule defines when you will declare the experiment done and write the results memo — regardless of whether the result is positive. Without it, experiments run until they happen to look good.

7. Draft the plan. Before finalizing, read back the primary metric and stopping rule to the user and confirm they match the proposal's success criteria.

## Template

See [experiment-plan-template.md](./experiment-plan-template.md).
