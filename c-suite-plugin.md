# C-Suite Plugin

This document describes the design of a plugin that emulates the executive officers of a corporation — a CEO, CFO, CTO, COO, CMO, and a few others — as a set of distinct review and decision-making roles you can convene on a project. It is a design description, not a built plugin. Where it makes a claim about what would help, that claim is a hypothesis from the same limited experience that produced the rest of this repository, and is flagged as such.

The roster is a starting assumption, not a fixed law: the officers described below (CEO, CFO, CTO, COO, CMO, CHRO, CLO, CISO) are the ones that map cleanly to recurring software-project decisions. Add or drop officers to fit the work; the test for whether an officer belongs is given later in this document.

## Why this exists, and where it does not

The honest risk for a plugin like this is that it becomes org-chart cosplay: a pile of personas that produce confident-sounding memos no one needed. So it helps to be precise about the one thing it is actually for.

The ecosystem already contains two standalone executive-perspective skills, and they are the proof that the underlying idea works. `plan-ceo-review` applies a founder's stance to a plan — rethink the problem, challenge the scope, ask whether this is ambitious enough. `cso` (Chief Security Officer mode) applies a security officer's stance to a codebase — supply chain, secrets, threat model. Each is useful because an *executive role is really a distinct evaluative stance*: a fixed set of questions, a domain it owns, and a concrete deliverable it produces. The role is a lens, not a costume.

This plugin does **not** replace or duplicate those two skills. It does two things they do not:

1. **It convenes multiple lenses on a single decision.** A real executive decision — should we build this, ship this, fund this — is contested across domains. The CFO's runway concern, the CTO's build-vs-buy judgment, and the CMO's positioning argument are all valid and frequently in tension. A *board review* runs several officer lenses against one proposal and surfaces where they disagree, rather than producing one smooth recommendation that has quietly buried the trade-off. The disagreement is the product.

2. **It gives executive decisions a durable governance spine.** The rest of this repository is built on the observation that unrecorded reasoning disappears between sessions. Strategy, budget assumptions, and the rationale for a kill-or-fund call decay the same way design intent does. The plugin keeps a small set of governing artifacts — a charter, a current strategy with measurable objectives, and a board-decision log — so that "we decided not to build X, here is why" survives to the session that proposes X again.

Where this plugin is genuinely useful: a decision that crosses domains and that you will have to defend or revisit later. Where it is just role-play, and should be skipped: a routine, single-domain task with an obvious owner. Convening a simulated board to decide whether to rename a function is theater. The plugin should make the heavyweight path available, not mandatory.

`plan-ceo-review` and `cso` remain usable on their own for single-lens work. The CEO and CISO officers in this plugin are the board-review-integrated versions of those same stances; the plugin references them rather than reimplementing them.

## The governance spine

Following the pattern of `agentic-workflow` (which loads `SPEC.md` / `DECISIONS.md` / `LESSONS.md`) and `research-workflow` (which loads the `research/` artifacts), this plugin maintains a small **`governance/`** directory, kept out of the repo root and committed as the project's executive memory.

- **`CHARTER.md`** — what the company or project is, who it serves, and the non-negotiables. The stable frame. Changes rarely; when it does, that is itself a board-level event.
- **`STRATEGY.md`** — the current direction and its measurable objectives (the OKR-style commitments). This is the document every officer review is implicitly scored against: a proposal that advances no stated objective is a finding, not a detail.
- **`BOARD.md`** — the decision log. Append-only. Each entry records a decision (fund / ship / build / kill / defer), the date, which officers were convened, where they disagreed, and the evidence that broke the tie. This is the artifact that makes a future "didn't we already decide this?" answerable.

The spine is wired through the same three hook points the sibling plugins use:

- **`SessionStart`** loads the `governance/` artifacts into context and emits a probe that asks for the current strategic frame before any executive review runs — so an officer is reasoning against the actual stated objectives, not an invented one.
- **`UserPromptSubmit`** re-injects a short standing rule: score proposals against `STRATEGY.md`, report when an officer's recommendation contradicts a prior `BOARD.md` decision, and never collapse a genuine cross-officer disagreement into false consensus.
- **`Stop`** gates session exit on recording any decision reached during the session into `BOARD.md`, including the dissent — mirroring the distillation gates in the other plugins. Its marker lives under a temp directory, never in the project, and stays silent until the project has been initialized.

There is deliberately no code-complexity gate here; that is a maintainability concern owned by `agentic-workflow`, which a software project can install alongside this one.

## The officers

Each officer is a skill: a distinct decision domain, a fixed set of questions, and one concrete deliverable. The discriminating test for whether an officer earns a place in the roster is simple and worth applying ruthlessly — **does it own a decision domain no other officer owns, and does it produce an output no other officer produces?** If two officers generate the same kind of memo, one of them is theater and should be cut.

By that test:

- **CEO — strategy and scope.** Owns: is this the right problem, and is the ambition right? Deliverable: a scope verdict (expand / hold / reduce) tied to `STRATEGY.md`. This is the board-integrated form of the existing `plan-ceo-review` skill.
- **CFO — cost, runway, and return.** Owns: what does this cost, what does it return, and can we afford it now? Deliverable: a cost/ROI memo with the runway impact and the assumptions the numbers depend on stated explicitly.
- **CTO — technical strategy and build-vs-buy.** Owns: is this technically sound, and should we build it, buy it, or not do it? Deliverable: a technical-direction recommendation with the load-bearing architectural risks named.
- **COO — execution and process.** Owns: can we actually deliver this with the people and process we have? Deliverable: an execution-feasibility assessment — sequencing, dependencies, and where the plan will bottleneck.
- **CMO — positioning and launch.** Owns: who is this for, why will they choose it, and how does it reach them? Deliverable: a positioning and go-to-market memo. (Sharpest on product work; often not convened for purely internal tooling.)
- **CHRO — people and organizational load.** Owns: who does this work, and what does it do to the team's capacity and morale? Deliverable: a staffing and organizational-impact note. (The officer most prone to cosplay on a solo or small project — convene it only when a decision genuinely turns on people, and skip it otherwise rather than manufacturing a memo.)
- **CLO — legal, licensing, and compliance.** Owns: what are we allowed to do here? Deliverable: a licensing/compliance/contractual-risk review — dependency licenses, data handling, regulatory exposure.
- **CISO — security and risk.** Owns: how does this get attacked, and what is the exposure? Deliverable: a threat assessment. This is the board-integrated form of the existing `cso` skill, which remains usable standalone.

Each officer's review is scored against `STRATEGY.md` and checked against `BOARD.md` for contradiction with past decisions. An officer that cannot connect its concern to a stated objective or a prior commitment is producing noise, and the skill should say so rather than dressing it up.

## Commands and the board workflow

- **`/c-suite-init`** scaffolds `governance/` with starter `CHARTER.md`, `STRATEGY.md`, and an empty `BOARD.md`. As with the sibling plugins, this is a starting set, not a required one.

- **`/board-review <proposal>`** is the convening workflow and the reason the plugin exists. Given a proposal — a plan file, a PR, a feature idea — it runs the relevant officer lenses against it, deliberately preserving disagreement rather than averaging it away, and produces a decision record: each officer's verdict, the points of conflict, a recommended call, and the evidence that would settle the open disputes. The output is appended to `BOARD.md` on a decision. Which officers are convened is a choice, not a default-all: a launch proposal pulls in CEO/CFO/CMO/CISO; an internal refactor pulls in CTO/COO and probably no one else. Convening every officer on every proposal is how this turns into theater.

- Individual officer skills (`/cfo-review`, `/cto-review`, and so on) can be invoked directly for single-lens work, the same way `plan-ceo-review` and `cso` are used today, without convening a board.

The intended division of labor matches the rest of this repository: the human is the actual board — the final judge of the trade-offs the officers surface. The plugin's job is to make sure each domain's objection is raised, recorded, and checked against what was decided before, so that a cross-cutting decision is made with the contested parts visible instead of quietly resolved by whoever drafted the proposal.

## Status

This is a design sketch, and the parts most likely to be wrong are the ones that sound most complete. The strongest claim — that convening multiple officer lenses on one decision and preserving their disagreement produces better decisions than a single synthesized recommendation — is a hypothesis, untested at the scale of the existing `plan-ceo-review` and `cso` skills. The roster is the weakest part: several officers (CHRO especially, CMO on internal work) will produce filler on many real projects, and the honest design response is to convene fewer officers more deliberately, not to complete the org chart for its own sake. Treat the board-review workflow as the load-bearing idea and the full eight-officer roster as a menu to draw from sparingly.
