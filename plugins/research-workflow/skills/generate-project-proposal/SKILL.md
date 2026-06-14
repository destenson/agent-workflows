---
name: generate-project-proposal
description: Draft a project proposal — "should we resource this effort?" Use when the primary question is about cost, timeline, and people rather than what to build or whether a hypothesis is true.
---

# Generate project proposal

A project proposal answers: should we commit resources to this effort? It can wrap a research, feature, or product proposal — in that case the inner proposal must already exist or be drafted alongside this one. The distinguishing characteristic is that cost, risk, and people are the load-bearing sections. A project proposal without a realistic resource estimate is not a proposal; it is a wish.

## How to run it

1. Ask: what is the deliverable? A project proposal must point to a concrete output — a shipped product, a validated hypothesis, a deployed system. If the deliverable is vague, the cost estimate will be meaningless.
2. Ask: does a research, feature, or product proposal exist for this work? If yes, link it. If no, decide whether to draft one alongside this or summarize the scope here instead.
3. Ask: who is needed and for how long? Name roles, not headcount. Dependencies on other teams or external vendors should be named explicitly.
4. Ask: what are the top three things that could cause this to fail or be delayed? These go in the cost & risk section. If the user can only name one, probe harder.
5. Ask: what is the fallback if the project is cancelled or stalled partway? Partial completion value and sunk cost exposure matter for resourcing decisions.

## Emphasis for this type

- **Cost & risk** — the primary section. Include: estimated timeline with milestones, named roles and approximate allocation, external dependencies, failure modes, and what partial completion is worth.
- **Problem / motivation** — keep it tight; this is often answered by the linked proposal. Summarize rather than re-argue.
- **Why now** — resource allocation has an opportunity cost. Explain what is being deferred or not done in order to fund this.
- **Success criteria** — include both technical and organizational success: what does done look like, and how will we know if the team executed well vs. the bet was wrong?

Keep brief:
- **Alternatives considered** — usually handled in the inner proposal; note here only if the project-level framing changes the alternatives (e.g., build vs. buy vs. contract out)

## Template

See [proposal-template.md](../generate-research-proposal/proposal-template.md) — use the `project` type.
