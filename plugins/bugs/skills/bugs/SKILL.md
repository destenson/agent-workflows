---
name: bugs
description: Add, update, or resolve entries in BUGS.md — the project's log of open, unfixed bugs — or pick one open bug from the log and fix it. Use when you find a bug you are not fixing now (deferred or out of scope) and want it on record, when you fix a bug already listed there (remove its entry), when asked to write or update the bug log, or when invoked with nothing specific to record — then read BUGS.md, choose an open bug, fix it, and remove its entry. Entries are removed when fixed, so the log tracks only what is still broken.
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

## Work a bug (fix one from the log)

When this skill is invoked with **nothing specific to record** — a bare `/bugs` with no bug to add and none you just fixed to remove — treat it as the user asking you to pick an open bug and fix it.

1. Read `BUGS.md`. If it does not exist or has no open entries, say so and stop — there is nothing to work.
2. Choose the **most actionable** open bug: prefer one with a clear repro and a localized cause over a vague or sprawling one. If the user named or pointed at a specific bug, use that instead.
3. State which entry you picked and why in one line before starting. If two are genuinely tied and the choice would send you down very different paths, ask which they want rather than guessing.
4. Fix it. Follow the project's normal practice — reproduce first if you can, make the change, and verify the fix actually resolves the symptom (run it, don't just assume).
5. On a confirmed fix, **remove its entry** per *Resolve a bug* above. If you could not fix it, leave the entry in place and update its **Notes** with what you learned (ruled-out causes, where the trail went cold) so the next attempt starts ahead.

## Keep it honest

- If an existing entry no longer matches reality — the bug is gone, or the symptom has changed — correct or remove it rather than leaving a stale claim for the next session to trust.
- Do not start working through the bug list on your own initiative. Adding and resolving entries is always in scope; fixing logged bugs is the user's call — a bare invocation of this skill (see *Work a bug*) is that call, but absent it, do not begin fixing logged bugs unprompted.
