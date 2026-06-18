---
name: handoff
description: Write, update, or clear HANDOFF.md — a rolling handoff for the next agent capturing what is done, what is in progress, what was discovered-but-not-started, the concrete next step, and gotchas. Use when wrapping up with work unfinished, when follow-up work has surfaced that is out of the current scope, or when asked to write or update a handoff. Also use to clear the handoff once the handed-over work is finished.
---

Maintain `HANDOFF.md` at the project root — a single rolling handoff that lets the next session resume without re-deriving context. This is transient working state, not durable project memory (decisions and lessons belong in the project's real memory, e.g. `DECISIONS.md` / `LESSONS.md` if you use the agentic-workflow plugin). Keep the handoff to what the next agent actually needs to continue.

## Write or update

If the HANDOFF.md file already exists, update it with the new session's state. If the session has made progress on the existing handoff, update the relevant sections and add any new discoveries or next steps. If the session has uncovered new information that changes the status or next steps, reflect that in the handoff as well.

If the HANDOFF.md file does not exist, synthesize the session state, then run the write script with a JSON payload on stdin. The script *only* creates `HANDOFF.md` mechanically.

```bash
cat <<'JSON' | bash "${CLAUDE_PLUGIN_ROOT}/scripts/write-handoff.sh"
{
  "as_of": "<date and HEAD commit if useful>",
  "status": "<one-line status, e.g. 'feature X half-built; auth test failing'>",
  "done": [
    "<what is genuinely complete and verified>"
  ],
  "in_progress": [
    "<what is partially done and exactly where it stands: the file, the failing test, the half-applied change>"
  ],
  "discovered": [
    "<work that surfaced this session but is out of the current change's scope — the main reason this file exists>"
  ],
  "next_steps": [
    "<the concrete next action, specific enough to resume without re-investigating>"
  ],
  "open_questions": [
    "<anything waiting on a human call or unresolved>"
  ],
  "gotchas": [
    "<what will mislead the next agent: a dead end already tried, a wrong-looking-but-correct thing, a flaky step>"
  ]
}
JSON
```

Fill from the actual session, not from intention. A short accurate handoff beats one padded with optimistic "done". The script will warn you if `HANDOFF.md` is not gitignored; show that message to the user and let them decide whether to add the ignore entry.

## Clear when the work is picked up

When the handed-over work has been fully resumed and finished, delete the handoff so the next session is not handed stale state. Before clearing, make sure anything durable — a decision made, a lesson learned — has been recorded in the project's real memory, not left only in the handoff.

Confirm with the user before clearing.
