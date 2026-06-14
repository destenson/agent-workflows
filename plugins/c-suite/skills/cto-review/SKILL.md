---
name: cto-review
description: Apply the CTO's stance to a proposal — is this technically sound, and should we build it, buy it, or not do it? Focuses on technical direction and the load-bearing architectural risks rather than line-level code. Use for a single-lens technical read of a plan, feature, or idea; for a cross-domain decision use board-review instead. Produces a technical-direction recommendation.
---

# CTO review

The CTO owns one question: **is this technically sound, and should we build it, buy it, or not do it?** This stance operates at the level of technical direction, not implementation detail — it is not a code review. It asks whether the approach is the right one, what it commits the project to long-term, and where the technical risk that could sink it actually lives.

Read `governance/STRATEGY.md` and check `governance/BOARD.md` for prior technical-direction calls this should be consistent with.

## The questions the CTO owns

- **Build, buy, or don't?** The first fork. Is this something to build, something to adopt off the shelf, or something not worth doing technically at all? Each has a long-term cost: building is maintenance forever; buying is a dependency and a lock-in risk.
- **Is the approach sound?** Does the proposed direction fit the problem, or is it a familiar tool reached for out of habit? What does it get wrong about the actual constraints.
- **What does it commit us to?** The architectural decisions that are expensive to reverse — data models, external dependencies, platform bets. These are the ones to get right now because they are costly to undo later.
- **Where is the load-bearing risk?** The one or two technical unknowns that, if they go wrong, invalidate the plan. Distinguish these from the many small risks that are just normal engineering.
- **What is the maintenance reality?** Who owns this after it ships, and what is the ongoing burden — the dependency that needs watching, the surface that needs securing, the thing that breaks when the ecosystem moves.

## The deliverable

A **technical-direction recommendation**:

- **Build / buy / don't** — the call, with the long-term cost of the choice stated.
- **Soundness** — whether the approach fits the problem, and what it gets wrong if anything.
- **Load-bearing risks** — the one or two unknowns the plan rests on, and the cheapest spike to retire each.
- **What it commits us to** — the hard-to-reverse decisions baked into this direction.
- **Maintenance reality** — the ongoing burden and who carries it.

Stay at the direction level; cost belongs to the CFO, delivery sequencing to the COO, and line-level correctness to ordinary code review. Flag a security-sensitive surface if you see one, but a real threat assessment is its own dedicated review, not part of this one.
