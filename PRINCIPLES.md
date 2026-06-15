# Principles

The workflows in this repository — agentic development, embedded-target, research, sysadmin, and c-suite — look different on the surface but rest on the same small set of ideas. This document states those ideas as a numbered, citable canon.

These principles concern the *operation of a coding agent during development*: how a human runs Claude Code sessions so that intent, assumptions, and lessons survive across sessions. This is a distinct concern from how to architect an LLM-powered application that you ship to production — that lower layer (tool calling, structured outputs, request handling) is largely provided by Claude Code itself, so the workflows here build on top of it rather than reimplementing it.

Everything here is a working hypothesis drawn from limited experience, not settled doctrine. The principles should be corrected wherever real project use falsifies them — the same standard the workflows hold their own specs to.

---

## Durable memory

### 1. Keep the "why" outside the code

Code records *what* the system does; it does not record why it was built that way, what was rejected, or what premise it rests on. An agent session optimizes the task in front of it, and any intent that was never written down does not carry to the next session. So the durable asset of a project is not its code but its recorded reasoning — the spec, the decisions, the assumptions, the lessons. These artifacts are loaded into every session precisely because the context window is lossy and the next session starts cold.

### 2. Negative knowledge is first-class

Surviving design leaves fossils in the code, so a fresh session can reconstruct it by reading. Dead ends leave nothing — the approach that was tried and failed is invisible once the diff is discarded, so the next session re-explores it. Recording what *failed and why* (the `LESSONS.md` artifact) is therefore higher-leverage and more often neglected than recording what worked. The bar for an entry is that it names a concrete mistake a future session would otherwise make; the most dangerous entries are the dead ends that look correct.

### 3. The spec is the asset; prefer restart to rehabilitation

With cheap agent labor, regenerating code from a corrected specification is cheap relative to rehabilitating a codebase that has drifted from its intent — not free, because a rewrite re-pays the micro-decisions that the old code absorbed silently, but cheap enough that restarting is a real option rather than a defeat. This only holds if the accumulated knowledge lives in the artifacts and not solely in the code. The spec is a maintained artifact, not immutable input: when implementation contradicts it, the spec is corrected and the falsification recorded before work continues.

---

## Structure over discipline

### 4. Make practice structural, not remembered

A practice that depends on someone remembering to do it gets skipped under load. Wherever possible, a practice is enforced by a hook, a gate, a script, or a CI check rather than by instruction. A few practices are irreducibly judgment-based (divergence reporting, pushback) and cannot be mechanized; those stay standing instructions, but they are kept few and short, because they decay like any instruction.

### 5. Inject against decay

Different hook events decay differently. A `SessionStart` injection is fresh at turn one and progressively buried as the context window fills, so anything that must stay live as the session runs belongs on a per-turn event (`UserPromptSubmit`) instead, re-asserted every turn. Match the injection point to how long the instruction must survive: one-shot context loading at session start, continuously-needed rules re-injected per turn, artifact re-reads after compaction.

### 6. Gate on a decision, not on content

A gate that demands output gets fed filler — compliance bias makes an agent produce a "lesson" to satisfy the gate, poisoning the journal with the noise the journal exists to prevent. So the end-of-session distillation gate blocks until the agent *either* writes entries *or* explicitly declares there are none, and declaring empty is the frictionless path. Most sessions genuinely produce nothing worth keeping; the honest empty declaration is the normal outcome, and the gate protects that.

---

## Contact with reality

### 7. Validate assumptions before building on them

A spec written by an implementer tends to be strong on mechanism and silently assumptive about the world. Before high-risk work begins, a fresh agent instance enumerates every premise the spec takes for granted and ranks each by cost-if-false; the costly-and-unvalidated ones get a throwaway spike whose only purpose is contact with reality. Implementation is gated: it does not start while a high-cost assumption remains unvalidated. The fresh instance critiques more honestly than the author would because it has no investment in the draft, and a single narrow task ("find the assumptions") produces sharper output than a generic review.

### 8. Verify by reproduction, not by inspection

A patch that looks right is a hypothesis, not a fix. The success signal is a reproduction that failed before the change and passes after it — and for environment- or timing-dependent bugs, "passes after" means passes end-to-end, repeatedly, under the real triggering condition, not once by hand. Closing a bug on a plausible-looking diff is how the same bug returns under a slightly different trigger. For a non-trivial bug, the primary artifact is often the understanding (root cause, ruled-out hypotheses) rather than the diff, and it must be recorded in proportion to what was learned, not to the size of the change.

### 9. Script the operating loop

A build→deploy→run→collect cycle stays hands-on only as long as it lives in someone's head as procedural knowledge. Once each step is a script with machine-readable output and a hard timeout, an agent can drive the whole cycle unattended. This matters most where the limiting resource is scarce: for environment-dependent bugs the bottleneck is occurrences of the triggering condition, not execution time, so the loop is built to extract maximum signal per occurrence (capture diagnostics first) and to synthesize the condition on demand where possible (fault injection).

---

## Human and agent

### 10. Human reviews; agent authors

The human acts as design reviewer and domain oracle, not design author. The agent drafts, implements, and iterates; the human critiques with an implementer's instincts (where will this hurt to build, what is underspecified, what will not survive real data) and answers the questions only the human can answer. The workflow leans on an asymmetry: recognizing a bad design is easier than authoring a good one.

### 11. Treat contorted agent behavior as a diagnostic signal

When an agent's behavior turns roundabout, or a fix keeps growing into a workaround layered on an earlier workaround, that is evidence, not just session noise. It often means the agent is dutifully satisfying a constraint that is false, or compensating for a structure that is wrong. The response is to check the spec for a bad assumption, or to stop patching and ask whether the module needs regenerating from a corrected understanding — not to add another layer.

### 12. Preserve disagreement; do not average it

When several review lenses (executive officers, or any set of distinct perspectives) examine one cross-domain decision, their disagreement is information. Collapsing it into a single consensus recommendation discards exactly the part a future reader needs to re-judge the call. So the governance spine records the decision *and its dissent*: what was chosen, and what the objecting perspective argued and why. Recorded dissent is the decision-level analogue of negative knowledge (factor 2).

---

## Why a numbered canon

These principles already live, in scattered form, across the individual workflow documents — as observations, standing rules, and lists of failure modes. Stating them once as a named, numbered set is not redundant: a principle that can be cited ("this violates factor 6") can be taught, referenced in review, and argued with, in a way that the same idea buried in prose cannot. The canon is the shared spine; each workflow document is the detailed application of these principles to one kind of work.
