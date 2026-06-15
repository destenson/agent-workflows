---
name: c-suite-init
disable-model-invocation: true
description: Scaffold the c-suite governance spine (CHARTER, STRATEGY, BOARD) in a governance/ directory, customized to the project by autodiscovery and a short interview. Use when the user asks to initialize, scaffold, or set up the project's governance spine or executive memory.
---

Scaffold the durable governance artifacts from the plugin's templates at `${CLAUDE_PLUGIN_ROOT}/templates/`, then customize them to *this* project rather than leaving raw placeholders. A blank charter and strategy steer nothing; the goal is a governance spine the officer and board-review skills can actually score proposals against from the first session.

Work in four phases: check, discover, copy, customize-and-interview.

## 1. Check what exists

The artifacts live in a dedicated **`governance/` directory**, not the project root, so they do not clutter the root. Create it if it does not exist.

Check which of `CHARTER.md`, `STRATEGY.md`, `BOARD.md` already exist. **Never overwrite an existing file** — it may hold a real, hand-written charter or strategy. Skip it entirely (no copy, no customization) and report it as skipped. The phases below apply only to files this run creates.

## 2. Discover the project's frame

Before writing anything, read the project to learn what it is and who it serves. This is a quick orientation pass, not a full audit — a few tool calls. Look at whatever exists:

- `README*`, `ABOUT*`, `docs/`, a top-level `*.md`, a landing page or pitch
- package/project metadata (`pyproject.toml`, `package.json`, `Cargo.toml`) for name and one-line description
- the recent `git log` subjects for what is being worked on now
- the code structure at a high level, to know the domain

From this, try to extract the `CHARTER.md` fields: the **project title**, **what this is** (one or two sentences), **who it serves** (the specific people and the job it does for them), **how it wins / why it persists**, and any **non-negotiables** stated outright (a licensing stance, a data-handling principle).

Do **not** try to discover or infer the **STRATEGY.md objectives and key results**. Those are commitments about where the project is going this period — they are decisions, not facts lying in a repo, and inventing them manufactures a bar nobody set. They come from the interview, or are left as explicit stubs.

## 3. Copy the templates

Run the scaffold helper, copying into `governance/` only files that do not already exist (it never overwrites):

```
"${CLAUDE_PLUGIN_ROOT}/scripts/scaffold.sh" "${CLAUDE_PLUGIN_ROOT}/templates" governance CHARTER.md STRATEGY.md BOARD.md
```

It prints `created <file>` / `skipped <file>` per file (and `missing-template <file>`, a packaging bug to surface, if a template is absent). The customize-and-interview phase below applies only to files this run created.

These three are the starter spine, not a required fixed set. A project can add others (a risk register, a metrics scoreboard) or drop ones that do not apply — but `BOARD.md` is what the Stop gate watches for to decide whether the plugin is active in this project, so keep it if you want the decision-recording nudge. `BOARD.md` is an empty log; it is not customized here.

## 4. Customize and interview

Fill `CHARTER.md` from what phase 2 found: the title, **What this is**, **Who it serves**, **How it wins / why it persists**, and any **Non-negotiables** stated outright. Mark every value you inferred rather than confirmed with a trailing `(inferred — confirm)` so the user can see what to check. Anything discovery could not supply stays as the original placeholder, so a gap is visible rather than silently blank.

Then interview the user for the facts discovery cannot supply — kept short, the few things that genuinely need a human:

- Confirm or correct the inferred charter, especially **Who it serves** and the **Non-negotiables** (the constraints no officer review may override — these matter because a proposal that violates one is rejected at the charter level).
- The **STRATEGY.md** core: the current **period**, the **direction/bet**, and the **objectives** with measurable **key results**. If the user has not set objectives yet, that is a legitimate answer — leave a clear stub noting the strategy is to be set, rather than inventing one. The officer and board-review skills score every proposal against `STRATEGY.md`, so an honest stub is better than a fabricated bar, and far better than a blank.

Set `STRATEGY.md`'s period and direction from the answers; leave anything the user is not ready to commit as a marked stub.

## Report

Tell the user: which files were created and which were skipped; what you filled into `CHARTER.md` and the source of each inferred value; and what still needs them (the strategy stubs especially). The `governance/` directory is meant to be committed; it is the project's executive memory. The plugin keeps no other state in the project — the board gate's pending-decision marker lives in the temp directory.
