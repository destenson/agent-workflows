# C-Suite Plugin

Convenes executive-officer review lenses on a single cross-domain decision and **preserves their disagreement** instead of averaging it into one smooth recommendation. An executive role is a distinct evaluative stance — a fixed set of questions, a domain it owns, a concrete deliverable — and a real decision (build / ship / fund / kill) is contested across those stances. A single review pass collapses that contest into whichever concern the reviewer finds most salient; a board review keeps it visible. The disagreement is the product.

## When to use it, and when not to

Use it for a decision that **crosses domains** and that you will have to defend or revisit later. Skip it for routine, single-domain work with an obvious owner — convening a simulated board to decide whether to rename a function is theater. The heavyweight path is available, not mandatory.

## The governance spine

A small **`governance/`** directory, kept out of the repo root and committed as the project's executive memory:

- `CHARTER.md` — what this is, who it serves, the non-negotiables. The stable frame.
- `STRATEGY.md` — the current period's objectives and measurable key results. Every officer scores a proposal against this; a proposal that advances no objective is a finding.
- `BOARD.md` — the append-only decision log, recording each call **and its dissent**, so a future "didn't we already decide this?" is answerable.

Unlike the sibling plugins, this one is intentionally light on hooks — an executive review is an on-demand act, not an always-on background discipline. The skills read `governance/` themselves when they run; there is no SessionStart probe and no per-turn standing rules. The one hook is a `Stop` gate:

- `Stop` → the board-decision gate. If a board review reached a decision this session that is not yet in `BOARD.md`, it nudges once before exit, then lets the next stop proceed. The handshake is explicit: `/c-suite:board-review` drops a pending-decision marker when it produces a verdict; recording the decision to `BOARD.md` clears it; the gate fires at most once. The marker lives in `${TMPDIR:-/tmp}/c-suite/`, never in the project, and the gate stays silent until `/c-suite:c-suite-init` has run.

There is deliberately **no complexity/line-cap gate** here — that is a code-maintainability concern owned by `agentic-workflow`, which a software project can install alongside this one.

**Skill:** `/c-suite:c-suite-init` scaffolds `governance/` with starter `CHARTER.md`, `STRATEGY.md`, and an empty `BOARD.md` — a starting set, not a required one. The `governance/` directory is meant to be committed; it is the project's executive memory.

## Skills

### The convening workflow

- [board-review](skills/board-review/SKILL.md) — run several officer lenses against one proposal, preserve where they disagree, recommend a call, and record the decision (with dissent) to `BOARD.md`. The reason the plugin exists.

### The officers — each a distinct stance with one deliverable

- [ceo-review](skills/ceo-review/SKILL.md) — is this the right problem, and is the ambition right? → scope verdict (expand / hold / reduce)
- [cfo-review](skills/cfo-review/SKILL.md) — what does it cost, what does it return, can we afford it now? → cost/ROI memo with runway impact
- [coo-review](skills/coo-review/SKILL.md) — can we deliver this with the people and process we have? → execution-feasibility assessment
- [cto-review](skills/cto-review/SKILL.md) — is it technically sound; build, buy, or don't? → technical-direction recommendation
- [cmo-review](skills/cmo-review/SKILL.md) — who is this for, why will they choose it, how does it reach them? → positioning and go-to-market memo
- [clo-review](skills/clo-review/SKILL.md) — what are we allowed to do here? → licensing/compliance/contractual-risk review

Each officer can be invoked directly for single-lens work, or convened by `/c-suite:board-review`. The roster is a menu to draw from sparingly — convening every officer on every proposal is how this turns into theater. It is deliberately incomplete: there is no security or people officer, because completing the org chart for its own sake is the failure mode the plugin is built to avoid.
