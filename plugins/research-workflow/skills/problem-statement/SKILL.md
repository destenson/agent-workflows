---
name: problem-statement
description: Draft a problem statement — the bounded, falsifiable description of what is wrong or unknown and who it affects. Use before writing a proposal of any type. A sharp problem statement is the prerequisite for a useful hypothesis.
---

# Problem statement

A problem statement does one thing: describes, with precision, what is wrong or unknown and why it matters. It is not a solution sketch. It is not a hypothesis. It is the thing a proposal responds to — and if the problem statement is vague, every document downstream will be vague too.

This is upstream of the proposal cluster. A problem statement feeds into the `proposal` node; it does not require one to exist yet.

## How to run it

1. Ask the user: what is wrong, missing, or unknown? Get the raw answer in their words before shaping it.

2. Ask: who experiences this problem, and in what context? The more specific the answer, the sharper the problem statement. "Researchers" is not specific enough. "ML engineers running multi-week training jobs on a shared cluster" is.

3. Ask: how does the current situation fail them? Get the actual failure mode — slowdowns, errors, missing information, wrong decisions — not an abstract description of inadequacy.

4. Ask: what is the cost of not solving this? This forces the user to articulate why the problem is worth addressing at all. If they can't answer it, the problem may not be worth a proposal.

5. Ask: what is out of scope? What adjacent problems will this statement explicitly not address? Boundaries prevent the problem from inflating into everything.

6. Draft the statement. A good problem statement is 2–4 sentences: who, what failure, in what context, at what cost. Read it back to the user. If they would add a solution to it, that is a sign the problem is not yet stated cleanly — strip the solution and try again.

## What a problem statement is not

- A solution: "We need a better scheduler" is a solution. "Jobs starve under the current FIFO scheduler when large jobs queue behind them" is a problem.
- A hypothesis: that comes later, in the proposal.
- A vision: "Imagine a world where..." is not a problem statement.

## Template

```
**Problem:** <What is wrong or unknown — one sentence.>

**Affected:** <Who experiences it, in what context.>

**Current failure:** <How the situation fails them today — specific behavior, not abstract inadequacy.>

**Cost of inaction:** <What is lost or risked if this is not addressed.>

**Out of scope:** <What adjacent problems this statement will not address.>
```
