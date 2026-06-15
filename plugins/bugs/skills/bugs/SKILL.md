---
name: bugs
description: Add, update, or resolve entries in BUGS.md — the project's log of open, unfixed bugs. Use when you find a bug you are not fixing now (deferred or out of scope) and want it on record, when you fix a bug already listed there (remove its entry), or when asked to write or update the bug log. Entries are removed when fixed, so the log tracks only what is still broken.
---

Maintain `BUGS.md` at the project root — the project's running list of **open, unfixed** bugs. It is durable project state (commit it), but it is not an append-only history: each entry exists only while the bug is open, and is removed the moment the bug is fixed. The log answers "what is currently broken," not "what was ever broken."

## Add a bug

Add a bug here when you find one this session that you are **not** fixing right now — it is deferred, out of scope for the current change, or simply not yet tackled. (A bug you are fixing this turn does not belong here; just fix it.)

1. If `BUGS.md` does not exist, create it from `${CLAUDE_PLUGIN_ROOT}/templates/BUGS.md`. If it exists, **add to it in place** — newest entry first — without disturbing the others.
2. Fill the entry from what you actually observed:
   - **Found** — the date.
   - **Where** — the file, module, command, or URL where it shows up.
   - **Symptom** — what goes wrong, observably.
   - **Repro** — the smallest steps or input that trigger it, if you know them.
   - **Notes** — suspected cause, why it was deferred, anything that saves the next person time. Optional. Link an issue or PR if one exists.
3. Keep it short enough to act on. Be honest about what you do and do not know — a "Repro: not yet isolated" is more useful than a confident guess.

## Resolve a bug (remove it)

When a bug listed in `BUGS.md` is fixed — whether you fixed it deliberately or it fell out of other work — **remove its entry**. Do not mark it "fixed" and leave it; do not move it to a "resolved" section. The log grows into noise if fixed bugs linger, so the fix and the removal go together. If the fix is worth remembering, that belongs in the commit message (and in the project's durable memory, e.g. `LESSONS.md` if you run the agentic-workflow plugin), not as a tombstone in the bug log.

## Keep it honest

- If an existing entry no longer matches reality — the bug is gone, or the symptom has changed — correct or remove it rather than leaving a stale claim for the next session to trust.
- Do not start working through the bug list on your own initiative. Adding and resolving entries is in scope; fixing logged bugs is the user's call unless they ask.
