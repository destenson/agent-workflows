---
name: continue
description: Continue work from HANDOFF.md — continue working from rolling handoff as the next agent, or when asked to continue from the handoff. Load the pending `HANDOFF.md` at session start so a new session resumes where the last left off, and give a non-blocking reminder to record unfinished and newly-discovered work before wrapping up.
---

## Load the handoff at session start

When a session starts, check for a pending `HANDOFF.md` at the project root. If it exists, load its contents and synthesize the state for the agent to continue from. This allows the next session to pick up where the last left off without needing to re-derive context.

If a handoff exists, read it and immediately state:

1. **What was done** — confirm completed work matches reality (check git status, file state)
2. **What is in progress** — identify the exact file, test, or change that was mid-flight
3. **What was discovered** — note any follow-up work surfaced but not started
4. **The next concrete step** — state the immediate action you will take to resume
5. **Staleness check** — flag anything in the handoff that no longer matches actual state (e.g., a "done" item that was reverted, a "next step" already completed, a "gotcha" that no longer applies)

Do not trust the handoff blindly. It is one session's account, not ground truth. Verify against the actual codebase before proceeding.

## Keep the handoff current

As you work, keep `HANDOFF.md` current using the `handoff` skill. Update it when:

- You make progress on in-progress work
- You discover new follow-up work outside the current scope
- You resolve open questions or encounter new gotchas
- The next steps change based on what you learn

The handoff is a living document during the session. It should reflect the current state, not the state at session start.

## Clear when the work is picked up

When the handed-over work has been fully resumed and finished, clear the handoff so the next session is not handed stale state. Before clearing:

1. Ensure anything durable — a decision made, a lesson learned — has been recorded in the project's real memory (e.g., `DECISIONS.md` / `LESSONS.md` if the project uses them), not left only in the handoff.
2. Confirm with the user before clearing, or clear if explicitly asked.

Remove HANDOFF.md if all work has been resumed and finished and no more work has arisen during the session.

## If no handoff exists

If there is no `HANDOFF.md` at the project root, proceed normally. The absence of a handoff means the previous session finished cleanly or this is a fresh start — no action needed.

