# Workflow Prompts & Artifact Templates

Companion to `agentic-dev-workflow.md`. These are the operational pieces: prompts to be emitted by hooks/skills, standing rules for project instructions, and templates for the durable artifacts. All are first drafts intended for refinement against real sessions.

---

## Prompts

### Session probe (SessionStart hook — scripted opener)
> Read SPEC.md, DECISIONS.md, LESSONS.md, and ASSUMPTIONS.md. Then summarize: (1) current project state, (2) the active constraints and invariants, (3) open/unvalidated assumptions, (4) the scope of the current PRP. Do not write or modify any code yet.

*Kill criterion:* the summary misstates project state, misses a key constraint, or shows confused reasoning → terminate the session and start a new one. No code before a passing probe.

### Design interview (elicitation)
> Act as the architect interviewing a domain expert. Your goal is to draft a spec; my role is to answer questions and critique drafts, not to author. Ask me questions in batches of 3–5 covering: the problem and who has it, success criteria, environment facts (data shapes, scale, runtime, integration points), hard constraints, explicit non-goals. After each batch, restate what you now believe to be true and ask me to correct it. When you can argue trade-offs without needing basics explained, draft the spec. State every premise you are relying on explicitly rather than building it in silently.

### Assumption audit (fresh instance, spec as only input)
> Your entire task is assumption extraction — do not review style, structure, or completeness. Enumerate every claim this specification takes for granted: about the environment, the data, library/tool behavior, performance characteristics, user behavior, and the problem itself. Include premises that are implied by the design rather than stated. For each: state the assumption in one sentence, classify cost-if-false (low/medium/high), and propose the cheapest possible test that would validate or falsify it. Output as an ASSUMPTIONS.md table.

### Spike mandate
> This is a throwaway spike. Its only purpose is to validate or falsify the following assumption: {assumption}. Build the minimum throwaway implementation that makes real contact with {the data / the library / the environment}. Do not generalize, do not handle errors beyond what the test needs, do not produce reusable code. End by stating: validated or falsified, the evidence, and any lessons for LESSONS.md.

### End-of-session distillation (Stop hook)
> Before this session ends, update the journals. In DECISIONS.md: append any non-obvious choices made this session and their rationale. In LESSONS.md: append every dead end hit this session — what was tried, why it failed, and what to do instead. Prioritize anything learned that is NOT visible in the code or spec. If a session genuinely produced nothing for a journal, state "no entries" explicitly rather than skipping it.

### Entropy-reduction pass (dedicated session)
> Mandate: reduce this codebase's complexity with zero new behavior. Permitted: deleting code, consolidating duplicate or near-duplicate implementations, removing special cases by fixing root causes, collapsing speculative abstraction. Forbidden: new features, new dependencies, new abstractions, behavior changes. All validation gates must pass before and after. Report: lines removed, duplicates consolidated, special cases eliminated, and anything you wanted to remove but couldn't — with the blocking reason recorded in LESSONS.md.

---

## Standing rules (project instructions / CLAUDE.md)

1. **Divergence reporting.** If the spec or any journal conflicts with what you observe in the code, data, or environment: stop and report the conflict. Never silently work around it — the workaround encodes the contradiction into the codebase. Work resumes only after the spec or assumption is corrected.
2. **Pushback obligation.** If a requested change violates DECISIONS.md, the spec, or a recorded lesson, flag it before implementing. Implementing a flagged change requires explicit confirmation.
3. **Journal-append.** Whenever you make a non-obvious choice or abandon an approach, append it to the relevant journal at the moment it happens, not at session end.
4. **Complexity budget.** Respect the configured caps (file length, dependency allowlist). A cap violation is a refactor-or-split decision point, not something to suppress.

---

## Artifact templates

### ASSUMPTIONS.md
```markdown
# Assumptions

| # | Assumption | Cost if false | Status | Validation | Evidence / spike |
|---|-----------|---------------|--------|------------|------------------|
| 1 | {one-sentence premise} | high | unvalidated | {cheapest test} | — |
| 2 | {…} | med | validated | {test} | {spike result, date} |
| 3 | {…} | high | falsified | {test} | {evidence}; spec corrected {date} |
```
Status values: `unvalidated`, `validated`, `falsified`. Gate: no implementation while any high-cost assumption is `unvalidated`. A `falsified` entry requires a spec correction before it is closed.

### DECISIONS.md (append-only)
```markdown
# Decisions

## {date} — {short title}
**Decision:** {what was chosen}
**Context:** {the situation that forced a choice}
**Rationale:** {why this option}
**Consequences:** {what this commits us to / rules out}
```

### LESSONS.md (append-only, negative knowledge)
```markdown
# Lessons

## {date} — {short title}
**Tried:** {approach}
**Failed because:** {root cause, specifically}
**Instead:** {what works, or "open"}
**Trap rating:** {how plausible the dead end looks to a fresh reader: low/med/high}
```
The `Trap rating` field exists because the most dangerous dead ends are the ones that look correct; high-trap entries deserve mention in the spec itself.

---

## Hook configuration sketch (Claude Code)

```jsonc
// .claude/settings.json (sketch — refine against current hook API)
{
  "hooks": {
    "SessionStart": [{
      "hooks": [{ "type": "command",
        "command": "cat .claude/prompts/session-probe.md" }]
    }],
    "Stop": [{
      "hooks": [{ "type": "command",
        "command": "check_journals_updated.sh"  // exits nonzero w/ distillation prompt if journals untouched this session
      }]
    }],
    "PreToolUse": [{
      "matcher": "Edit|Write",
      "hooks": [{ "type": "command",
        "command": "complexity_gate.sh"  // blocks edits to files over budget; emits refactor-or-split instruction
      }]
    }]
  }
}
```
The two shell gates are intentionally small: `check_journals_updated.sh` compares journal mtimes against session start; `complexity_gate.sh` checks the target file's line count against the cap.
