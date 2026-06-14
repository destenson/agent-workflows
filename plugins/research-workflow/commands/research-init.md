---
description: Scaffold the research workflow in this project — a research/ directory with the common starter artifacts (abstract, proposal, experiments, results).
---

Scaffold the durable research artifacts from the plugin's templates at `${CLAUDE_PLUGIN_ROOT}/templates/`. For each file below, copy it only if it does not already exist; never overwrite an existing file — report it as skipped instead.

The artifacts live in a dedicated **research directory**, not the project root, so they do not clutter the root and bulky per-experiment material can live in subdirectories without being auto-loaded into context. The directory is `$RESEARCH_DIR` if that environment variable is set, otherwise `research/`. The session-start hook announces the resolved directory at the top of the session; use that value. Create the directory if it does not exist.

Copy into the research directory (call it `<research>/`):
- `<research>/abstract.md` ← `templates/abstract.md`
- `<research>/proposal.md` ← `templates/proposal.md`
- `<research>/experiments.md` ← `templates/experiments.md`
- `<research>/results.md` ← `templates/results.md`

These four are the **common** starter set, not a required fixed set. Research artifacts vary with the work — tell the user they can add others (a hypothesis register, a literature scan, a data management plan) or drop ones that do not apply. Every top-level `.md` in the research directory is loaded into context at session start; deeper material (per-experiment run logs, configs, outputs) belongs in subdirectories so it is not auto-loaded.

After copying, tell the user what to fill in first: `<research>/abstract.md` (the question and live hypothesis) and `<research>/proposal.md` (hypotheses and pre-committed success criteria). The proposal-generation and experiment-design skills produce the fuller versions; these templates hold the durable core. The research directory is meant to be committed — it is the project's research memory. The plugin keeps no other state in the project; the distillation gate's once-per-session marker lives in the temp dir.

Report which files were created and which were skipped.
