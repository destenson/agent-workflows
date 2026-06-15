# prototype-to-product

A Claude Code / Codex plugin for the messy middle between "the prototype works" and "this is ready to put in front of someone." It keeps that work in one durable artifact — `HARDENING.md`, a ledger of the gaps between the current prototype and a pre-release bar — and ships three skills that build the ledger, set the bar, and work it down.

It is deliberately not a quality grader or a generic best-practices checklist. The gaps are derived from *your* prototype against a bar *you* set for a specific audience, so the convert phase fixes what actually blocks release instead of gold-plating.

## The phases

1. **`assess-prototype`** — reads the prototype and writes a concrete, locatable list of what is prototype-grade and below a pre-release bar into `HARDENING.md`. Re-runnable as the prototype evolves: it augments the ledger in place and never clobbers it. Finds gaps; doesn't fix them.
2. **`define-release-target`** — sets the **release bar** (what "pre-release" means for this product, for its intended audience) and prioritizes each ledger item as must-fix-for-release or deferred. If a `SPEC.md` exists (the agentic-workflow plugin), the bar *extends* it rather than restating its success criteria.
3. **`convert-prototype`** — works the must-fix items down one at a time: smallest change that meets the item's "Done when" condition, verified against that condition, committed alone, then removed from the ledger (the commit is the record). Stops at the bar, not at an empty ledger.

All three are manual-only (`disable-model-invocation: true`) — they write to the ledger or rewrite the prototype, so they run only when you invoke them.

## What it does automatically

The hooks engage only once a `HARDENING.md` exists, so the plugin is silent until you run `assess-prototype`:

- `SessionStart` → loads `HARDENING.md` (the active worklist) into context and emits the session probe.
- `UserPromptSubmit` → re-injects the hardening standing rules every turn (one item per commit; surface failures, don't paper over them; hold the bar both ways), so they don't get buried as context fills. These are additive to the agentic-workflow rules — they don't repeat them.
- `Stop` → a non-blocking, once-per-session reminder to keep the ledger current (remove closed items, record newly-found gaps).

## Composes with agentic-workflow

This plugin owns the prototype→pre-release transition; it does not replace the base development loop. When run alongside `agentic-workflow`:

- `SPEC.md`'s success criteria and hard constraints stay the source of truth for *what the product does*; the release bar records only the *productization* conditions on top (a prototype can meet SPEC and still hardcode secrets, crash on bad input, or only run on the author's machine).
- A hardening item that resists can record its dead end in `DECISIONS.md`/`LESSONS.md` rather than the ledger's Notes.

Neither plugin requires the other.

## Install

### Claude Code

```
/plugin marketplace add destenson/agent-workflows
/plugin install prototype-to-product@agent-workflows
```

### Codex

```
/plugins marketplace add ./.agents/plugins/marketplace.json
/plugins install prototype-to-product
```

Then, in a prototype you want to harden:

```
/prototype-to-product:assess-prototype     # Claude Code
@assess-prototype                           # Codex
```

## Requirements

- `jq` and `bash` on PATH (the hook scripts parse hook JSON with `jq`).

## State

The reminder's once-per-session marker lives in the temp dir (`${TMPDIR:-/tmp}/prototype-to-product/`), keyed by session id — never in the project. The plugin leaves nothing in the working tree but `HARDENING.md` itself, so there is nothing extra to `.gitignore`.
