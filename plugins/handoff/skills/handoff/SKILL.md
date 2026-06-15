---
name: handoff
description: Write, update, or clear HANDOFF.md — a rolling handoff for the next agent capturing what is done, what is in progress, what was discovered-but-not-started, the concrete next step, and gotchas. Use when wrapping up with work unfinished, when follow-up work has surfaced that is out of the current scope, or when asked to write or update a handoff. Also use to clear the handoff once the handed-over work is finished.
---

Maintain `HANDOFF.md` at the project root — a single rolling handoff that lets the next session resume without re-deriving context. This is transient working state, not durable project memory (decisions and lessons belong in the project's real memory, e.g. `DECISIONS.md` / `LESSONS.md` if you use the agentic-workflow plugin). Keep the handoff to what the next agent actually needs to continue.

## Write or update

1. If `HANDOFF.md` does not exist, create it from `${CLAUDE_PLUGIN_ROOT}/templates/HANDOFF.md`. If it already exists, **update it in place** — merge the current state into the existing sections rather than discarding what is still true.
2. Fill it from the actual session, not from intention:
   - **Done** — what is genuinely complete and verified.
   - **In progress** — what is partially done and exactly where it stands: the file, the failing test, the half-applied change.
   - **Discovered — not yet started** — work that surfaced this session but is out of the current change's scope. This is the main reason the handoff exists; capture it rather than letting it evaporate.
   - **Next steps** — the concrete next action, specific enough to act on without re-investigating.
   - **Open questions / decisions pending** and **Gotchas** — anything that will mislead the next agent (a dead end already tried, a wrong-looking-but-correct thing, a flaky step).
3. Set **As of** to the current date and, where useful, the HEAD commit. Be honest about status: a short accurate handoff beats one padded with optimistic "done".

## Keep it honest and local

- If something in an existing handoff no longer matches the code or state, correct it — do not leave stale claims for the next session to trust.
- The handoff is local session state by default. On first creation, if this is a git repository and `HANDOFF.md` is not already ignored, offer to add it to `.gitignore` — show the line and let the user decide. Do not commit or ignore it silently. (If the user wants the handoff to travel to a teammate or another machine, they can choose to commit it instead.)

## Clear when the work is picked up

When the handed-over work has been fully resumed and finished, clear the handoff so the next session is not handed stale state: delete `HANDOFF.md`, or reset it to the empty template, after confirming with the user. Before clearing, make sure anything durable — a decision made, a lesson learned — has been recorded in the project's real memory, not left only in the handoff.
