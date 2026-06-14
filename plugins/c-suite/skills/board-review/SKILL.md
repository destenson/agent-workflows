---
name: board-review
description: Convene multiple executive-officer lenses (CEO/CFO/COO/CTO/CMO/CLO) on one cross-domain decision and preserve their disagreement instead of averaging it into a single smooth recommendation. Use for a decision that crosses domains and that will have to be defended or revisited later — should we build / ship / fund / kill this. Produces a board decision record and appends it to governance/BOARD.md. Skip it for routine single-domain work with an obvious owner.
---

# Board review

The reason this plugin exists. A cross-domain decision — build it, ship it, fund it, kill it — is contested across domains that a single review pass collapses into whichever concern the reviewer finds most salient. A board review runs several officer lenses against one proposal and **keeps the disagreement visible**. The disagreement is the product. Do not resolve every conflict into one recommendation; a board review that produces a frictionless consensus has usually buried the trade-off.

The human is the actual board — the final judge. This skill's job is to make sure each domain's objection is raised, recorded, and checked against what was decided before.

## Before convening: is a board even warranted?

If this is routine, single-domain work with an obvious owner — renaming a function, a localized refactor, a copy tweak — say so and stop. Convening a board on it is theater. Suggest the single relevant officer skill instead, or just proceeding. The heavyweight path is available, not mandatory.

## Load the governing context

Read whichever of these exist:
- `governance/CHARTER.md` — the non-negotiables. A proposal that violates one is rejected at the charter level, before any cost or feasibility argument.
- `governance/STRATEGY.md` — the current objectives. Every officer scores the proposal against these.
- `governance/BOARD.md` — past decisions. If this proposal contradicts a prior decision, that is the first thing to surface.

If `governance/` does not exist, tell the user to run `/c-suite-init` first, or proceed without the spine and note that the review is ungrounded (no strategy to score against, no log to check). Do not invent objectives.

## Choose who to convene — not everyone

Convening every officer on every proposal is how this turns into theater. Pick the officers whose domain the proposal actually touches:

- A **launch / new product** decision → CEO, CFO, CMO (and CLO if there is licensing or data exposure).
- An **internal refactor / infra** decision → CTO, COO. Probably no one else.
- A **fund / kill / resourcing** decision → CEO, CFO, COO.
- A **dependency / licensing / data-handling** decision → CLO, CTO.

State which officers you convened and why, and — just as important — which you deliberately left out. An officer convened reflexively produces filler.

## Run each lens, independently

For each convened officer, apply that officer's stance from its skill (`ceo-review`, `cfo-review`, `coo-review`, `cto-review`, `cmo-review`, `clo-review`) and produce that officer's verdict and its load-bearing concerns. Run them as genuinely different readers: do not let the CFO's verdict soften the CTO's. Each officer must connect its concern to a `STRATEGY.md` objective or a `BOARD.md` precedent; an officer that cannot is producing noise and should say so rather than dress it up.

## Surface the conflict, then recommend

Assemble the decision record. The structure that keeps disagreement visible:

1. **Each officer's verdict** — one line each, in their own terms (e.g. CFO: defer, runway too thin this quarter; CTO: build, the buy option locks us in).
2. **Where they disagree** — the real conflicts, stated as conflicts. This is the section that earns the whole exercise. Do not smooth it.
3. **Recommended call** — your synthesis: fund / ship / build / buy / kill / defer, with the reasoning. It is legitimate for this to side with one officer over another — say which, and why.
4. **What would settle the open disputes** — the evidence or test that would turn a contested call into a clear one. Often the most useful output: it tells the human what to go find out.

Present this to the user. They make the call.

## Record the decision

The moment the review produces a verdict (even a provisional one), drop the pending-decision marker so the Stop gate will nudge if the decision goes unrecorded:

```bash
mkdir -p "${TMPDIR:-/tmp}/c-suite" && touch "${TMPDIR:-/tmp}/c-suite/pending-decision"
```

When the user settles on a decision, append an entry to `governance/BOARD.md` using the block in that file — and crucially record the dissent, not just the verdict. Then clear the marker:

```bash
rm -f "${TMPDIR:-/tmp}/c-suite/pending-decision"
```

If the review was exploratory and reached no decision, do not write a BOARD entry; remove the marker and say so. A forced entry is noise. If the decision reverses a prior `BOARD.md` entry, reference it in the new entry's `Supersedes` field rather than editing the old one — the log is append-only.
