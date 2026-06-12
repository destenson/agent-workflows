# Agentic Development Workflow

A workflow for AI-agent-driven software development designed around three observations:

1. **Agents optimize locally by default.** A session solves the task in front of it, and whatever architectural intent isn't written down doesn't carry over to the next session. Code records the *what*; the *why* survives only in durable artifacts.
2. **Discipline decays; structure doesn't.** A practice that depends on remembering to do it tends to get skipped under load. Wherever possible, practices are enforced by a hook, a gate, or a scripted prompt rather than memory. A few are irreducibly judgment-based (divergence reporting, pushback) and must remain standing instructions; those are kept few, short, and re-injected every session, because they decay like any instruction.
3. **The spec is the durable asset, not the code.** With agent labor, regenerating code from a good specification is cheap relative to rehabilitating a drifted codebase — not free (the restart protocol below covers what regeneration re-pays), but cheap enough that restarting is a realistic option rather than a defeat, provided the accumulated knowledge lives outside the codebase.

These observations, and the more specific claims about agent behavior throughout, are working hypotheses from limited experience — the workflow is itself a spec, to be corrected where real projects falsify it.

## Roles

The human acts as **design reviewer and domain oracle**, not design author. The agent drafts; the human critiques with implementer's instincts (where will this hurt to build, what's underspecified, what won't survive real data) and answers questions only the human can answer. Recognizing a bad design is easier than authoring a good one; the workflow leans on that asymmetry.

## Durable Artifacts

Every project maintains four documents. Hooks keep them loaded and updated (see Automation).

| Artifact | Contents | Updated by |
|---|---|---|
| `SPEC.md` / PRPs | What to build, why, validation gates | Corrected whenever reality falsifies it |
| `ASSUMPTIONS.md` | Every premise the spec rests on, each with status: `unvalidated` / `validated-as-of` / `falsified`, and a risk rank | Assumption audit; spikes |
| `DECISIONS.md` | Non-obvious choices and their rationale (ADR-lite, append-only) | Continuous, during sessions |
| `LESSONS.md` | **Negative knowledge**: dead ends, why they failed, things that look right but aren't | Continuous + end-of-session distillation |

`LESSONS.md` is probably the highest-leverage artifact and is certainly the easiest to neglect. Surviving design leaves fossils in the code; dead ends leave nothing, so fresh sessions re-explore them. A healthy LESSONS.md is mostly "don't do X because Y." The bar for an entry: it must name the concrete mistake a future session would make without it. No named mistake, no entry — filler dilutes the real lessons and taxes every SessionStart injection.

`validated` is never terminal. A spike validates an assumption under the conditions of the spike — `validated-as-of` records that context (which spike, what data, when), and the assumption returns to scrutiny when those conditions change.

The spec is a **maintained artifact, not immutable input**. When implementation contradicts it, the spec is corrected before work continues, and the falsification is recorded.

## Lifecycle

### 1. Design elicitation (interview)
The agent interviews the human: requirements, constraints, success criteria, environment facts. The agent drafts the spec/PRPs from the answers. Interview-driven drafting surfaces premises that solo spec-writing leaves implicit — specs written by implementers tend to be strong on mechanism and silently assumptive about the world.

### 2. Assumption audit
A **fresh agent instance** receives the draft spec with a single task: enumerate every claim the document takes for granted, and rank by cost-if-false. Output populates `ASSUMPTIONS.md`. The reasoning: a fresh instance has no investment in the draft, so it critiques more honestly than the author would; and a single narrow task ("find the assumptions") tends to produce sharper results than a generic review request, which mostly comes back as style feedback.

**Gate:** implementation does not begin while high-risk assumptions remain `unvalidated`.

### 3. Spikes
Each high-risk unvalidated assumption gets a small throwaway implementation whose only purpose is contact with reality. Spike code is discarded; the validated/falsified status and any lessons are kept. Spikes are cheap with agent labor — prefer spiking to blind implementation wherever the spec is speculative.

### 4. Implementation sessions
Short, single-PRP-scoped sessions, opened and closed by scripted prompts:

- **Open — session probe.** First message (injected by hook): *"Summarize the current project state, active constraints, and open assumptions, from SPEC, DECISIONS, LESSONS, ASSUMPTIONS."* A bad summary kills the session before any code is touched: sessions vary in quality from their very first response, a confused opening summary is an early sign of a session that will go badly, and discarding one at that point costs almost nothing. The probe also pulls the four documents into context, so quality screening and context loading happen in one step.
- **Standing rules** (in project instructions): divergence reporting — *if the spec conflicts with observed reality, stop and report; never work around it* (silent workarounds encode the contradiction into the code); pushback — *refuse to implement anything violating DECISIONS/SPEC without flagging it*; journal-append on any non-obvious choice or dead end.
- **Close — distillation.** Stop hook fires: *"If this session produced anything a future session would otherwise re-learn the hard way — a dead end and why it failed, a non-obvious choice and its rationale — record it in LESSONS.md / DECISIONS.md. Most sessions produce nothing; declaring empty is the normal outcome."* The hook gates on a **decision, not content**: exit is blocked until the agent either writes entries or explicitly declares empty, and declaring empty is the frictionless path. A gate that demands content gets fed filler — compliance bias poisons the journal with the noise the journal exists to prevent.

Roundabout or contorted agent behavior is a **diagnostic signal**, not just session noise: it often means the agent is dutifully satisfying a constraint that is false. Check the spec for a bad assumption before blaming the session.

### 5. Bug investigation sessions
A bug is not a PRP. Implementation starts from a spec item and ends in a diff; a bug investigation starts from observed wrong behavior and ends — sometimes — somewhere other than a diff. The distinction matters because the default framing ("fix the bug") quietly assumes the artifact is code, and for a non-trivial bug that assumption discards most of what the session produced.

- **The fix is verified by reproduction, not by inspection.** A patch that looks right is a hypothesis, not a fix. The gate is a repro that failed before the change and passes after it — and for bugs whose trigger is environmental or timing-dependent, "passes after" means passes end-to-end, repeatedly, under the real condition, not once by hand. (The extension documents make this concrete: a checked-in on-device repro for the embedded loop, an N-cycle reconnect repro for the GStreamer fork.) Closing a bug on a plausible diff is how the same bug returns under a slightly different trigger.
- **The primary artifact is sometimes understanding, not the diff.** A real investigation produces a root cause, a set of ruled-out hypotheses, and occasionally a constraint that explains several other symptoms at once. When the eventual fix is one line — or zero lines, because the right response is "don't do that" or "this is a known limitation" — the diff captures almost none of that, and the understanding evaporates when the session closes unless it is written down. This is the negative-knowledge problem LESSONS.md exists for, sharpened: the ruled-out hypotheses are exactly the dead ends a fresh session would re-explore, and a root cause that explains multiple symptoms earns a DECISIONS.md entry even when nothing was decided to build, because it changes how the next reader interprets those symptoms. Record findings in proportion to what was learned, not to the size of the diff.
- **A stubborn bug is a diagnostic signal about the implementation.** When a bug resists fixing across several sessions, or the only available fix is a workaround layered on an earlier workaround, the bug has stopped being a defect and become evidence. The roundabout-agent-behavior signal above has a structural analogue here: a fix that keeps needing to grow more contorted is often compensating for a structure that is wrong. The response is to stop patching and ask whether the module — or the design — needs the restart protocol (§7) at smaller scope: regenerate the piece from a corrected understanding rather than add another layer. The accumulated investigation knowledge is what makes that affordable, because code is cheap to regenerate but the understanding of *why the old structure failed* is the one thing a rewrite cannot reconstruct from the discarded code. An attempt budget makes the escalation concrete: after N failed fix attempts, the session's job changes from "fix it" to "record what is now ruled out and what the failures imply about the structure," and a fresh session decides patch-or-rewrite from that brief.

### 6. Entropy-reduction passes
On a fixed cadence (e.g., every N PRPs), a dedicated session whose only mandate is: *delete code, consolidate duplicates, reduce special cases; no new behavior; validation gates must still pass.* Agents do this work well when it is the explicit task; expected as an implicit virtue alongside feature work, it tends not to happen. Complexity budgets (file-length caps, dependency allowlist) are enforced by lint/CI — failing checks don't decay the way instructions do.

The mandate covers the artifacts, not just the code: consolidate DECISIONS.md, delete LESSONS.md entries that no longer apply or never prevented anything, dedupe ASSUMPTIONS.md. The documents are injected into every session, so their entropy is a context tax paid on every turn — they need the deletion pass more than the code does. Append-only is the rule *within* sessions (no agent quietly rewriting history); the entropy pass is the one place curation happens.

### 6. Project restart protocol
When the codebase is judged off-track, regenerate rather than rehabilitate: new implementation from corrected `SPEC.md` + `DECISIONS.md` + `LESSONS.md` + `ASSUMPTIONS.md`. These carry forward the *recorded* knowledge, minus the entropy. What they cannot carry is the unrecorded knowledge — the micro-decisions below the journaling threshold that the old code absorbed silently (data-shape accommodations, edge cases hit once and fixed inline). A restart re-pays those. Well-maintained artifacts make restarting much cheaper than rehabilitation; they do not make it free, and the restart decision should be priced accordingly.

## Automation

Manual touchpoints reduce to: answering interview questions, reviewing drafts, judging spike results, and killing bad sessions. Everything else fires automatically.

**Claude Code hooks** (sketch):
- `SessionStart` — inject SPEC, DECISIONS, LESSONS, ASSUMPTIONS into context; emit the session probe as the scripted opener.
- `Stop` — fires when the agent is about to finish, *before* it actually stops, and can block the stop with a reason fed back to the agent — so it functions as the pre-stop gate. It emits the distillation prompt and blocks exit until the agent writes entries or explicitly declares empty. It checks that a decision was made, never that content was produced.
- `PreToolUse` (optional) — warn on edits to files exceeding the complexity budget, surfacing the refactor-or-split decision early. Enforcement lives in CI; the hook is advance notice, because a hard mid-task block strands the agent in awkward partial states.

**Skill candidates:**
- `design-interview` — runs the elicitation interview and drafts the spec/PRPs (extends prp-generation's context-gathering stage).
- `assumption-audit` — fresh-instance assumption extraction with risk ranking; writes ASSUMPTIONS.md.
- `session-retrospective` — the distillation ritual, with explicit negative-knowledge prompting.
- `entropy-pass` — the deletion-only refactor session with its mandate and validation gates.
- `project-docs-init` extension — scaffold ASSUMPTIONS.md, DECISIONS.md, LESSONS.md alongside existing doc scaffolding.

## Failure modes this workflow targets

- Spec contains hidden invalid assumptions → assumption audit + spikes + divergence reporting.
- Agent compliance bias implements bad ideas enthusiastically → pushback rules + adversarial fresh-instance review.
- Good design intent lost on restart → continuous journaling + distillation; restart from artifacts.
- Dead ends re-explored by fresh sessions → LESSONS.md negative knowledge.
- Entropy accumulation (patches layered on patches) → entropy passes + complexity budgets in CI.
- Journal poisoned by forced-completion filler → decision-gated (not content-gated) distillation + named-mistake bar for entries + artifact pruning in entropy passes.
- Low-quality session starts → the session probe at open; a bad summary means kill and restart.
- Bug closed on a plausible patch, returns under a new trigger; or its investigation discarded because the diff was small → reproduction-gated fixes + findings recorded in proportion to what was learned (§5).
- Symptom patched repeatedly while the structural cause persists → stubborn-bug-as-signal: escalate to the restart protocol at module scope rather than adding another workaround layer.
- Discipline items skipped under load → hooks make them structural where possible; the judgment-based remainder stays short and is re-injected every session.
