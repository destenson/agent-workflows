# handoff

A standalone plugin for handing in-flight work from one session to the next. When a session ends with work unfinished — or with follow-up work discovered along the way — the agent records it in a rolling `HANDOFF.md`, and the next session loads that file at startup and resumes from it instead of re-deriving the context.

It is deliberately its own plugin so it can be enabled or disabled at will, independently of the development, research, and sysadmin workflows. It does not depend on any of them.

## How it works

- `SessionStart` → if a `HANDOFF.md` exists at the project root, it is loaded into context with a short probe asking the agent to confirm what was done / in progress / discovered, state its next step, and flag anything in the handoff that no longer matches the actual state. Silent when there is no handoff.
- `Stop` → a **non-blocking**, once-per-session reminder (via `systemMessage`) to record unfinished or newly-discovered work in `HANDOFF.md` before wrapping up — or, if a handoff is already in play, to keep it current. It never blocks the session from ending; Stop fires every turn, so a per-session marker (in the temp dir, never in the repo) keeps it to one reminder.

There is no SessionStart artifact to scaffold and no `/init` step — the handoff is created on demand the first time you write one.

## Skill

- [handoff](skills/handoff/SKILL.md) — write, update, or clear `HANDOFF.md`. Captures **Done**, **In progress**, **Discovered — not yet started**, **Next steps**, **Open questions**, and **Gotchas**. Invoked as `/handoff:handoff` in Claude Code or `@handoff` in Codex.

## The file

A single rolling `HANDOFF.md` at the project root, updated in place and cleared once the work is picked up. It is **local working state by default** — the skill offers to add it to `.gitignore` on first creation. If you want a handoff to travel to a teammate or another machine, you can choose to commit it instead.

The handoff holds transient in-flight state, not durable project memory: decisions and lessons belong in the project's real memory (for example, `DECISIONS.md` / `LESSONS.md` if you also run the agentic-workflow plugin), and should be recorded there before the handoff is cleared.

## Install

```
/plugin marketplace add destenson/agent-workflows
/plugin install handoff
```

Under Codex: `/plugins marketplace add ./.agents/plugins/marketplace.json` then `/plugins install handoff`.
