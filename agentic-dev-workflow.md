# Agentic Development Workflow

A workflow for AI-agent-driven software development designed around three observations:

1. **Agents are greedy local optimizers.** Each turn solves the immediate task with no persistent architectural intent. Code carries the *what*; the *why* must live in durable artifacts or it is lost.
2. **Discipline decays; structure doesn't.** Any practice that depends on remembering to do it will be skipped under load. Every practice in this workflow is enforced by a hook, a gate, or a scripted prompt — never by memory.
3. **The spec is the durable asset, not the code.** Code is cheap to regenerate from a good specification. A project restart is a build step, not a defeat — provided the accumulated knowledge lives outside the codebase.

## Roles

The human acts as **design reviewer and domain oracle**, not design author. The agent drafts; the human critiques with implementer's instincts (where will this hurt to build, what's underspecified, what won't survive real data) and answers questions only the human can answer. Recognizing a bad design is far easier than authoring a good one; the workflow exploits that asymmetry.

## Durable Artifacts

Every project maintains four documents. Hooks keep them loaded and updated (see Automation).

| Artifact | Contents | Updated by |
|---|---|---|
| `SPEC.md` / PRPs | What to build, why, validation gates | Corrected whenever reality falsifies it |
| `ASSUMPTIONS.md` | Every premise the spec rests on, each with status: `unvalidated` / `validated` / `falsified`, and a risk rank | Assumption audit; spikes |
| `DECISIONS.md` | Non-obvious choices and their rationale (ADR-lite, append-only) | Continuous, during sessions |
| `LESSONS.md` | **Negative knowledge**: dead ends, why they failed, things that look right but aren't | Continuous + end-of-session distillation |

`LESSONS.md` is the highest-value artifact and the most commonly missing one. Surviving design leaves fossils in the code; dead ends leave nothing, so fresh sessions re-explore them. A healthy LESSONS.md is mostly "don't do X because Y."

The spec is a **maintained artifact, not immutable input**. When implementation contradicts it, the spec is corrected before work continues, and the falsification is recorded.

## Lifecycle

### 1. Design elicitation (interview)
The agent interviews the human: requirements, constraints, success criteria, environment facts. The agent drafts the spec/PRPs from the answers. Interview-driven drafting surfaces premises that solo spec-writing leaves implicit — specs written by implementers tend to be strong on mechanism and silently assumptive about the world.

### 2. Assumption audit
A **fresh agent instance** receives the draft spec with a single task: enumerate every claim the document takes for granted, and rank by cost-if-false. Output populates `ASSUMPTIONS.md`. A fresh instance attacks a draft more honestly than its author does, and "find the assumptions" as the *entire job* outperforms generic review, which yields style feedback.

**Gate:** implementation does not begin while high-risk assumptions remain `unvalidated`.

### 3. Spikes
Each high-risk unvalidated assumption gets a throwaway tracer-bullet implementation whose only purpose is contact with reality. Spike code is discarded; the validated/falsified status and any lessons are kept. Spikes are cheap with agent labor — prefer spiking to blind implementation wherever the spec is speculative.

### 4. Implementation sessions
Short, single-PRP-scoped sessions, opened and closed by scripted prompts:

- **Open — session probe.** First message (injected by hook): *"Summarize the current project state, active constraints, and open assumptions, from SPEC, DECISIONS, LESSONS, ASSUMPTIONS."* A bad summary kills the session before any code is touched — initialization variance is real and detectable from the first response; killing early is cheap sampling. The probe also forces the docs into context, so screening and context-loading are one move.
- **Standing rules** (in project instructions): divergence reporting — *if the spec conflicts with observed reality, stop and report; never work around it* (silent workarounds encode the contradiction into the code); pushback — *refuse to implement anything violating DECISIONS/SPEC without flagging it*; journal-append on any non-obvious choice or dead end.
- **Close — distillation.** Stop hook fires: *"Record in DECISIONS.md any non-obvious choices made this session, and in LESSONS.md any dead ends and why they failed — anything learned that is not visible in the code or spec."*

Roundabout or contorted agent behavior is a **diagnostic signal**, not just session noise: it frequently means the agent is satisfying a false constraint. Check the spec for a bad assumption before blaming the session.

### 5. Entropy-reduction passes
On a fixed cadence (e.g., every N PRPs), a dedicated session whose only mandate is: *delete code, consolidate duplicates, reduce special cases; no new behavior; validation gates must still pass.* Agents perform well at this when it is the explicit task rather than an implicit virtue. Complexity budgets (file-length caps, dependency allowlist) are enforced by lint/CI — failing checks don't decay the way instructions do.

### 6. Project restart protocol
When the codebase is judged off-track, regenerate rather than rehabilitate: new implementation from corrected `SPEC.md` + `DECISIONS.md` + `LESSONS.md` + `ASSUMPTIONS.md`. Together these contain everything the old codebase knew, minus the entropy. The restart decision is cheap *only if* the artifacts have been maintained — which is what the hooks guarantee.

## Automation

Manual touchpoints reduce to: answering interview questions, reviewing drafts, judging spike results, and killing bad sessions. Everything else fires automatically.

**Claude Code hooks** (sketch):
- `SessionStart` — inject SPEC, DECISIONS, LESSONS, ASSUMPTIONS into context; emit the session probe as the scripted opener.
- `Stop` — emit the distillation prompt; refuse clean exit until DECISIONS/LESSONS updates are written or explicitly declared empty.
- `PreToolUse` (optional) — block edits to files exceeding the complexity budget; force a refactor-or-split decision.

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
- Entropy accumulation / scar-tissue patches → entropy passes + complexity budgets in CI.
- Low-quality session initializations → probe-and-kill at session open.
- Discipline items skipped under load → hooks make them structural.
