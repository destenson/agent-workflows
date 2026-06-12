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

### Bug investigation (session mandate)
> You are investigating observed wrong behavior, not implementing a spec item. **Reproduce first:** produce a check that fails *because of this bug* before changing anything — a plausible-looking patch with no failing repro is a guess, not a fix. Then localize, fix, and confirm the same repro passes (end-to-end, under the real triggering condition, for environment- or timing-dependent bugs). Three things may outlast this session, and only one of them is the diff: (1) every hypothesis you ruled out and why — the dead ends a future session would otherwise repeat (LESSONS.md); (2) the root cause, especially if it explains other symptoms (DECISIONS.md when it reframes how the system is understood). Record these in proportion to what you learned, not to the size of the fix: a one-line change can be the conclusion of an investigation worth a page. If after {N} attempts the fix keeps growing into a workaround on top of earlier workarounds, stop — that is evidence the implementation is structurally wrong, not that you need a cleverer patch. Write down what the failures imply about the structure and hand off the patch-or-rewrite decision rather than forcing another layer.

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

These bindings are implemented as a plugin in `plugins/agentic-workflow/`; the JSON below mirrors that plugin's `hooks/hooks.json` (which uses `${CLAUDE_PLUGIN_ROOT}` so the commands resolve wherever the plugin is installed). The same JSON works in a project's `.claude/settings.json` if you point the commands at real paths instead. Refine against the current hook API before relying on it.

```jsonc
// plugins/agentic-workflow/hooks/hooks.json
{
  "hooks": {
    "SessionStart": [{
      "hooks": [{ "type": "command",
        // cats SPEC/ASSUMPTIONS/DECISIONS/LESSONS if present, then the session probe
        "command": "${CLAUDE_PLUGIN_ROOT}/scripts/session-start.sh" }]
    }],
    "UserPromptSubmit": [{
      "hooks": [{ "type": "command",
        // re-injects the standing rules every turn so they don't decay as context fills
        "command": "${CLAUDE_PLUGIN_ROOT}/scripts/standing-rules.sh" }]
    }],
    "PreToolUse": [{
      "matcher": "Edit|Write",
      "hooks": [{ "type": "command",
        // advisory only (never blocks): warns when the target file is over COMPLEXITY_BUDGET_LINES
        "command": "${CLAUDE_PLUGIN_ROOT}/scripts/complexity-gate.sh" }]
    }],
    "Stop": [{
      "hooks": [{ "type": "command",
        // blocks the first stop of a session with the distillation prompt, then allows the next
        "command": "${CLAUDE_PLUGIN_ROOT}/scripts/distillation-gate.sh" }]
    }]
  }
}
```

Notes on the gates as implemented:

- `session-start.sh` is one-shot context loading; the standing rules moved to `UserPromptSubmit` (`standing-rules.sh`) because a once-per-session injection decays as the window fills, and the judgment-based rules are exactly the ones that must stay live.
- `complexity-gate.sh` is **advisory** — it parses the tool's `file_path` from hook JSON (`jq`), compares the file's line count against `COMPLEXITY_BUDGET_LINES` (default 1000), and warns. It never blocks; enforcement belongs in CI, and a hard mid-task block strands the agent in partial states.
- `distillation-gate.sh` gates on a **decision being prompted, not content being produced**. It writes a per-session marker (`.agentic-workflow/state/`, keyed by `session_id`) and blocks once with the distillation prompt; the next stop is allowed whether the agent wrote entries or declared empty. An mtime comparison was rejected because it can't recognize "declare empty" and so would force filler — the failure the decision-gate exists to avoid. A shell hook can't tell a real lesson from filler regardless, so the honesty of the entry rides on the standing rules, not the gate.
- Not yet wired (described in `agentic-dev-workflow.md`, deferred until the base hooks are exercised): `SubagentStop` to gate fresh-instance audits/spikes, and `PreCompact` to re-read the artifacts after compaction.
