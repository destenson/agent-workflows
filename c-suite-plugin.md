# C-Suite Plugin

This document describes the design of a plugin that emulates the executive officers of a corporation — a CEO, CFO, COO, CTO, CMO, and CLO — as a set of distinct review and decision-making roles you can convene on a project. It is a design description for a self-contained plugin, built to be run against the user's own projects and ventures. Where it makes a claim about what would help, that claim is a hypothesis from the same limited experience that produced the rest of this repository, and is flagged as such.

The roster is a starting assumption, not a fixed law. The six officers below are a lean core that earns its place on recurring software-project decisions, plus one extra (CLO) for the licensing and compliance questions this repository already cares about. Add or drop officers to fit the work; the test for whether an officer belongs is given later in this document. The roster is deliberately incomplete — there is no security or people officer here, because completing the org chart for its own sake is exactly the failure mode this plugin is trying to avoid.

## Why this exists, and where it does not

The honest risk for a plugin like this is that it becomes org-chart cosplay: a pile of personas that produce confident-sounding memos no one needed. So it helps to be precise about the one thing it is actually for.

The useful idea underneath an "executive role" is that it is a distinct *evaluative stance*: a fixed set of questions, a domain it owns, and a concrete deliverable it produces. A CFO reading a proposal is not a CTO reading the same proposal — they look for different failures, weigh different costs, and would sign off for different reasons. The role is a lens, not a costume. A single review pass by one generalist reviewer tends to collapse those distinct concerns into whichever one the reviewer happens to find most salient.

This plugin does two things a single review pass does not:

1. **It convenes multiple lenses on a single decision.** A real executive decision — should we build this, ship this, fund this — is contested across domains. The CFO's runway concern, the CTO's build-vs-buy judgment, and the CMO's positioning argument are all valid and frequently in tension. A *board review* runs several officer lenses against one proposal and surfaces where they disagree, rather than producing one smooth recommendation that has quietly buried the trade-off. The disagreement is the product.

2. **It gives executive decisions a durable governance spine.** The rest of this repository is built on the observation that unrecorded reasoning disappears between sessions. Strategy, budget assumptions, and the rationale for a kill-or-fund call decay the same way design intent does. The plugin keeps a small set of governing artifacts — a charter, a current strategy with measurable objectives, and a board-decision log — so that "we decided not to build X, here is why" survives to the session that proposes X again.

Where this plugin is genuinely useful: a decision that crosses domains and that you will have to defend or revisit later. Where it is just role-play, and should be skipped: a routine, single-domain task with an obvious owner. Convening a simulated board to decide whether to rename a function is theater. The plugin should make the heavyweight path available, not mandatory.

## The governance spine

Following the pattern of `agentic-workflow` (which keeps `SPEC.md` / `DECISIONS.md` / `LESSONS.md`) and `research-workflow` (which keeps the `research/` artifacts), this plugin maintains a small **`governance/`** directory, kept out of the repo root and committed as the project's executive memory.

- **`CHARTER.md`** — what the company or project is, who it serves, and the non-negotiables. The stable frame. Changes rarely; when it does, that is itself a board-level event.
- **`STRATEGY.md`** — the current direction and its measurable objectives (the OKR-style commitments). This is the document every officer review is implicitly scored against: a proposal that advances no stated objective is a finding, not a detail.
- **`BOARD.md`** — the decision log. Append-only. Each entry records a decision (fund / ship / build / kill / defer), the date, which officers were convened, where they disagreed, and the evidence that broke the tie. This is the artifact that makes a future "didn't we already decide this?" answerable.

Unlike the sibling plugins, this one is intentionally light on hooks. The governing artifacts are read by the skills themselves when an officer or board review runs — there is no SessionStart probe and no per-turn standing-rule re-injection, because an executive review is an on-demand act, not an always-on background discipline. The one hook is a **`Stop` gate** that protects the second pillar: if a board review reached a decision during the session and it has not yet been written to `BOARD.md`, the gate nudges once before exit, then lets the next stop proceed. The handshake is explicit — `/board-review` drops a pending-decision marker when it produces a verdict, recording the decision to `BOARD.md` clears it, and the gate fires (at most once) only while the marker exists. Its marker lives under a temp directory, never in the project, and the gate stays silent until the project has been initialized.

There is deliberately no code-complexity gate here; that is a maintainability concern owned by `agentic-workflow`, which a software project can install alongside this one.

## The officers

Each officer is a skill: a distinct decision domain, a fixed set of questions, and one concrete deliverable. The discriminating test for whether an officer earns a place in the roster is simple and worth applying ruthlessly — **does it own a decision domain no other officer owns, and does it produce an output no other officer produces?** If two officers generate the same kind of memo, one of them is theater and should be cut.

By that test:

- **CEO — strategy and scope.** Owns: is this the right problem, and is the ambition right? Deliverable: a scope verdict (expand / hold / reduce) tied to `STRATEGY.md`.
- **CFO — cost, runway, and return.** Owns: what does this cost, what does it return, and can we afford it now? Deliverable: a cost/ROI memo with the runway impact and the assumptions the numbers depend on stated explicitly.
- **COO — execution and process.** Owns: can we actually deliver this with the people and process we have? Deliverable: an execution-feasibility assessment — sequencing, dependencies, and where the plan will bottleneck.
- **CTO — technical strategy and build-vs-buy.** Owns: is this technically sound, and should we build it, buy it, or not do it? Deliverable: a technical-direction recommendation with the load-bearing architectural risks named.
- **CMO — positioning and launch.** Owns: who is this for, why will they choose it, and how does it reach them? Deliverable: a positioning and go-to-market memo. (Sharpest on product work; often not convened for purely internal tooling.)
- **CLO — legal, licensing, and compliance.** Owns: what are we allowed to do here? Deliverable: a licensing/compliance/contractual-risk review — dependency licenses, data handling, regulatory exposure.

Each officer's review is scored against `STRATEGY.md` and checked against `BOARD.md` for contradiction with past decisions. An officer that cannot connect its concern to a stated objective or a prior commitment is producing noise, and the skill should say so rather than dressing it up.

## Commands and the board workflow

- **`/c-suite-init`** scaffolds `governance/` with starter `CHARTER.md`, `STRATEGY.md`, and an empty `BOARD.md`. As with the sibling plugins, this is a starting set, not a required one.

- **`/board-review <proposal>`** is the convening workflow and the reason the plugin exists. Given a proposal — a plan file, a PR, a feature idea — it runs the relevant officer lenses against it, deliberately preserving disagreement rather than averaging it away, and produces a decision record: each officer's verdict, the points of conflict, a recommended call, and the evidence that would settle the open disputes. On a decision, the record is appended to `BOARD.md` and the pending-decision marker is cleared. Which officers are convened is a choice, not a default-all: a launch proposal pulls in CEO/CFO/CMO; an internal refactor pulls in CTO/COO and probably no one else. Convening every officer on every proposal is how this turns into theater.

- Individual officer skills (`/cfo-review`, `/cto-review`, and so on) can be invoked directly for single-lens work, without convening a board.

The intended division of labor matches the rest of this repository: the human is the actual board — the final judge of the trade-offs the officers surface. The plugin's job is to make sure each domain's objection is raised, recorded, and checked against what was decided before, so that a cross-cutting decision is made with the contested parts visible instead of quietly resolved by whoever drafted the proposal.

## Status

This is a design for a working plugin, and the parts most likely to be wrong are the ones that sound most complete. The strongest claim — that convening multiple officer lenses on one decision and preserving their disagreement produces better decisions than a single synthesized recommendation — is a hypothesis, not a measured result. The roster is the weakest part: CMO on internal work, and any officer convened reflexively, will produce filler on many real projects, and the honest design response is to convene fewer officers more deliberately, not to complete the org chart for its own sake. Treat the board-review workflow as the load-bearing idea and the six-officer roster as a menu to draw from sparingly.
