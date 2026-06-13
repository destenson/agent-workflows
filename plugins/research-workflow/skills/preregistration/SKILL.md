---
name: preregistration
description: Write a preregistration — a public or internal commitment to an analysis plan, made before data is collected or results are seen. Use for empirical ML work to prevent post-hoc rationalization of results. Produced alongside or immediately after the experiment plan.
---

# Preregistration

A preregistration is a timestamped commitment to an analysis plan, made before data is seen. Its purpose is to prevent the most common form of result distortion in empirical work: choosing the analysis method, metric, or stopping criterion after seeing which choice makes the results look best. This is not a problem of bad intent — it is a structural property of iterative analysis that makes post-hoc choices look like pre-planned ones.

In applied ML and engineering research, full public preregistration is rare but internal preregistration is practical and high-value. A preregistration does not need to be published — it needs to be timestamped and not modified after data is seen.

## When to use this

After the experiment plan is drafted and before any data collection, model training, or result inspection begins. If you have already seen preliminary results, a preregistration cannot be retroactively applied to those results — note this if it applies.

## How to run it

1. Ask the user: has any data been collected or any results been seen for this experiment? If yes, the preregistration applies only to analyses not yet run — state this boundary explicitly in the document.

2. Ask: what is the primary analysis? The specific comparison or computation that will be used to evaluate the hypothesis. This must be specific enough that two people given the same data would run the same analysis.

3. Ask: what is the decision rule? Given the primary analysis result, what is the criterion for confirming or falsifying the hypothesis? This should match the experiment plan's threshold exactly.

4. Ask: what secondary analyses are planned? List them. Any analysis not listed here will be treated as exploratory when the results are reported — this is not a penalty, it is a labeling convention that allows readers to correctly calibrate confidence.

5. Ask: what are the exclusion criteria? Under what conditions will data points, runs, or trials be excluded from the analysis? These must be specified now — excluding data post-hoc without a pre-committed criterion is a form of result manipulation, even when unintentional.

6. Ask: what is the sample size or number of runs, and is it determined by a stopping rule (from the experiment plan) or fixed in advance? If adaptive, state the rule.

7. Draft the preregistration. After drafting, the document should be timestamped — committed to version control, logged in an experiment tracker, or otherwise given an immutable record. Note where the timestamp lives.

## Template

See [preregistration-template.md](./preregistration-template.md).
