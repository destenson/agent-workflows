# agentic-workflow

A Claude Code plugin implementing the base workflow in [`agentic-dev-workflow.md`](../../agentic-dev-workflow.md). It moves the parts of the workflow that decay under load — discipline you'd otherwise have to remember — into hooks that fire automatically, and ships the discretionary rituals as skills.

## What it does

**Hooks** (automatic):
- `SessionStart` → loads `SPEC.md`, `ASSUMPTIONS.md`, `DECISIONS.md`, `LESSONS.md` into context and emits the session probe. One-shot context load.
- `UserPromptSubmit` → re-injects the standing rules (divergence reporting, pushback, journal-append) every turn, so they don't get buried as context fills.
- `PreToolUse(Edit|Write)` → advisory warning when the target file exceeds the complexity budget. Never blocks; enforcement belongs in CI. Override the cap with `COMPLEXITY_BUDGET_LINES` (default 1000).
- `Stop` → the distillation gate. Blocks the first stop of a session with the distillation prompt, then allows the next. It gates on the agent being *prompted to decide*, not on content being produced — declaring "no entries" is the frictionless exit, which keeps forced-completion filler out of the journals.

**Skills** (invoke when relevant): `design-interview`, `assumption-audit`, `spike`, `bug-investigation`, `session-retrospective`, `entropy-pass`.

**Command:** `/project-docs-init` scaffolds the four durable artifacts from `templates/`.

## Install

From this repo (it carries a marketplace manifest at the repo root):

```
/plugin marketplace add /home/dennis/src/agent-workflows
/plugin install agentic-workflow
```

Then, in a project you want to run the workflow in:

```
/project-docs-init
```

## Requirements

- `jq` and `bash` on PATH (the hook scripts parse hook JSON with `jq`).

## Known limitations of the scaffold

- The distillation gate prompts once per session and then trusts the agent. A shell hook can't tell a real lesson from filler, so the *honesty* of the distillation decision still rides on the standing rules, not on the gate. This is deliberate — a content-demanding gate produces filler.
- `SubagentStop` and `PreCompact` bindings (gating fresh-instance audits/spikes; re-reading artifacts after compaction) are described in the workflow doc but not wired here yet. Add them once the base hooks have been exercised against a real project.
- The complexity gate's feedback goes to stderr (advisory). If you want it surfaced into the model's context instead, switch it to JSON hook output.

## State

The distillation gate's once-per-session marker lives in the temp dir (`${TMPDIR:-/tmp}/agentic-workflow/`), keyed by session id — never in the project. The plugin leaves nothing in the working tree but the durable artifacts (SPEC/ASSUMPTIONS/DECISIONS/LESSONS) themselves, so there is nothing extra to `.gitignore`.
