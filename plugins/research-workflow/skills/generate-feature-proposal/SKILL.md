---
name: generate-feature-proposal
description: Draft a feature proposal — "should we add this to a thing that exists?" Use when the ask is scoped to an existing product and the decision is user/maintenance cost vs. value.
---

# Generate feature proposal

A feature proposal answers one question: should we add this to what we already have? It is scoped against an existing product, so the alternatives section and the scope boundary do most of the work. A feature that cannot be bounded is a product proposal in disguise — redirect it if that is the case.

## How to run it

1. Ask the user: what existing product or system does this attach to? If the answer is "a new thing," this is a product proposal, not a feature proposal.
2. Ask: who specifically is asking for this, and what are they trying to do? User/customer evidence matters more here than in other proposal types.
3. Ask: what is explicitly out of scope? The non-goals section is where feature proposals earn their rigor — if they can't say what this won't do, the scope is not yet defined.
4. Ask: have we considered not building this (do-nothing), buying or integrating an existing solution, or building a stripped-down version? If they haven't, walk through each before drafting.
5. Draft the proposal using the template below. Do not combine "proposed approach" with "why this approach" — keep the description of the solution separate from the argument for it.

## Emphasis for this type

- **Problem / motivation** — who has the problem, how often, what does it cost them today? User evidence (quotes, tickets, usage data) is the strongest signal here.
- **Scope & non-goals** — the non-goals do most of the work. Be explicit about what adjacent problems this feature will not solve.
- **Alternatives considered** — build vs. buy vs. do-nothing is mandatory. "We didn't consider alternatives" is a reason to reject.
- **Cost & risk** — maintenance burden matters as much as build cost. Features are forever; account for that.

## Template

See [proposal-template.md](../generate-research-proposal/proposal-template.md) — use the `feature` type.
