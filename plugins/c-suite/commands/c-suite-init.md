---
description: Scaffold the c-suite governance spine in this project — a governance/ directory with starter CHARTER.md, STRATEGY.md, and an empty BOARD.md.
---

Scaffold the durable governance artifacts from the plugin's templates at `${CLAUDE_PLUGIN_ROOT}/templates/`. For each file below, copy it only if it does not already exist; never overwrite an existing file — report it as skipped instead.

The artifacts live in a dedicated **`governance/` directory**, not the project root, so they do not clutter the root. Create the directory if it does not exist.

Copy into `governance/`:
- `governance/CHARTER.md` ← `templates/CHARTER.md`
- `governance/STRATEGY.md` ← `templates/STRATEGY.md`
- `governance/BOARD.md` ← `templates/BOARD.md`

These three are the starter spine, not a required fixed set. A project can add others (a risk register, a metrics scoreboard) or drop ones that do not apply — but `BOARD.md` is what the Stop gate watches for to decide whether the plugin is active in this project, so keep it if you want the decision-recording nudge.

After copying, tell the user what to fill in first: `governance/CHARTER.md` (what this is, who it serves, the non-negotiables) and `governance/STRATEGY.md` (the current period's objectives and measurable key results). The officer and board-review skills score every proposal against `STRATEGY.md`, so an empty strategy makes those reviews weaker — but it is fine to start with a rough charter and sharpen it. The `governance/` directory is meant to be committed; it is the project's executive memory. The plugin keeps no other state in the project — the board gate's pending-decision marker lives in the temp directory.

Report which files were created and which were skipped.
