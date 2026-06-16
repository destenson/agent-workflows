# bugs

A standalone plugin for keeping a project's open bugs from getting lost. When the agent finds a bug it is not fixing right now — deferred, out of scope, or just not yet tackled — it records it in a `BUGS.md` at the project root. Each session is reminded that the log exists and that found-but-unfixed bugs belong there, and a session that fixes one of the listed bugs removes its entry, so the log always reflects only what is still open.

It is deliberately its own plugin so it can be enabled or disabled at will, independently of the development, research, and sysadmin workflows. It does not depend on any of them.

## Opt-in

The plugin **activates only once a `BUGS.md` exists** at the project root — that file is how a project opts into keeping a bug log. Until it exists, both hooks stay silent; the plugin will not prompt you to start one. To begin, create `BUGS.md` (the `bugs` skill will scaffold it from the template on request), and from then on the hooks engage.

## How it works

- `SessionStart` → if a `BUGS.md` exists, a short notice states that the project keeps a bug log and gives the standing instruction: record any found-but-unfixed bug there, and remove an entry when its bug is fixed. It **does not print the file's contents** — a durable bug log grows, and loading it every session is needless context bloat; the agent reads `BUGS.md` on demand when it actually needs the open list. Silent when there is no `BUGS.md`.
- `Stop` → a **non-blocking**, once-per-session reminder (via `systemMessage`) to record any bug found-but-unfixed this session, and to remove the entry for any logged bug that got fixed. It never blocks the session from ending; Stop fires every turn, so a per-session marker (in the temp dir, never in the repo) keeps it to one reminder. Fires only when a `BUGS.md` exists.

## Skill

- [bugs](skills/bugs/SKILL.md) — add, update, or resolve entries in `BUGS.md`. Adds a bug found-but-unfixed; removes an entry when its bug is fixed. Invoked bare with nothing to record, it instead picks the most actionable open bug from the log, fixes it, and removes the entry. Invoked as `/bugs:bugs` in Claude Code or `@bugs` in Codex.

## The file

A single `BUGS.md` at the project root listing **open, unfixed** bugs. Unlike a transient handoff, it is **durable project state — commit it.** But it is not append-only history: each entry lives only while its bug is open and is removed when the bug is fixed, so the file tracks what is currently broken rather than growing into a changelog of everything ever fixed. What is worth remembering about a fix belongs in the commit message and the project's durable memory, not as a tombstone in the bug log.

## Install

```
/plugin marketplace add destenson/agent-workflows
/plugin install bugs
```

Under Codex: `/plugins marketplace add ./.agents/plugins/marketplace.json` then `/plugins install bugs`.
