---
name: research-init
disable-model-invocation: true
description: Scaffold the research workflow in this project — a research/ directory with the common starter artifacts (abstract, proposal, experiments, results), customized to the project by autodiscovery and a short interview. Use when the user asks to initialize, scaffold, or set up the project's research workspace.
---

Scaffold the durable research artifacts from the plugin's templates at `${CLAUDE_PLUGIN_ROOT}/templates/`, then customize them to *this* project rather than leaving raw placeholders. A blank template loaded every session is dead weight; the goal is an abstract that actually frames the work from the first session.

Work in four phases: discover, copy, customize, interview-for-gaps.

## 1. Resolve the directory and check what exists

The artifacts live in a dedicated **research directory**, not the project root. The directory is `$RESEARCH_DIR` if that environment variable is set, otherwise `research/`. The session-start hook announces the resolved directory at the top of the session; use that value. Create it if it does not exist.

Check which of the four target files already exist. **Never overwrite an existing file** — an existing artifact may hold real, hand-written content. Skip it entirely (no copy, no customization) and report it as skipped. The phases below apply only to files this run creates.

## 2. Discover the project's framing

Before writing anything, read the project to learn what it is actually about. This is a quick orientation pass, not a full audit — spend a few tool calls, not an investigation. Look at whatever exists:

- `README*`, `ABOUT*`, `docs/`, design docs, a top-level `*.md`
- existing notes in the research directory, and any papers/PDFs or `notes/` in the repo
- package/project metadata (`pyproject.toml`, `package.json`, `Cargo.toml`) for name and one-line description
- the recent `git log` subjects for what is being worked on
- the code structure only at a high level (top-level packages/modules), to know the domain

From this, try to extract: the **project title**, the **research question** (what is this trying to find out), **why it matters** (the decision or capability downstream), and the rough **scope / non-goals**. Note where each fact came from so you can show your sources.

Do **not** try to discover or infer the **live hypothesis** or the **success / decision criteria**. Those are commitments, not facts lying around in a repo — inventing them would manufacture a bar nobody set, which is exactly what the research standing rules forbid. They come from the interview, or are left as explicit stubs.

## 3. Copy the templates

Copy each missing file from `templates/` into the research directory (call it `<research>/`):

- `<research>/abstract.md` ← `templates/abstract.md`
- `<research>/proposal.md` ← `templates/proposal.md`
- `<research>/experiments.md` ← `templates/experiments.md`
- `<research>/results.md` ← `templates/results.md`

These four are the **common** starter set, not a required fixed set — the user can add others (a hypothesis register, a literature scan, a data management plan) or drop ones that do not apply. Every top-level `.md` in the research directory is loaded into context at session start; deeper material (per-experiment run logs, configs, outputs) belongs in subdirectories so it is not auto-loaded.

## 4. Customize what you discovered

Fill the placeholders in the copied files with what phase 2 found:

- Replace `{project title}` in all four files with the real title.
- In `abstract.md`, fill **Question**, **Why it matters**, and **Scope / non-goals** from discovery. Set **Status** to `framing`. Leave **Hypothesis (live)** for the interview.
- In `proposal.md`, fill **Approach** and **Out of scope** if discovery supports them; leave **Hypotheses** and **Success / decision criteria** for the interview.
- Leave `experiments.md` and `results.md` as empty running logs (title aside) — they fill in as work happens; the example rows stay as the format guide.

Mark every value you inferred rather than confirmed with a trailing `(inferred — confirm)` so the user can see what to check. Anything discovery could not supply stays as the original placeholder text, so a gap is visible rather than silently blank.

## 5. Interview for the gaps

Now ask the user only for the key facts discovery could not supply — primarily the **live hypothesis** and any **success/decision criteria** they are ready to commit to, plus confirmation or correction of the inferred Question and Why-it-matters. Keep it short: ask for the few things that genuinely need a human, not a questionnaire. If a fact does not exist yet (no hypothesis formed, no criteria set), that is a legitimate answer — leave a clear stub noting it is to be set, and point at the skill that produces it (`generate-research-proposal` for hypotheses, `experiment-design` for criteria). Do not pressure a commitment that is not ready; a bar set just to fill a blank is worse than an honest stub.

Apply the answers to `abstract.md` and `proposal.md`.

## Report

Tell the user: which files were created and which were skipped; for created files, what you filled in and the source of each inferred value; and what still needs them (the stubs, and which skill produces the fuller version). The fuller proposal and experiment plans come from the dedicated skills — this seeds the durable core so the framing is live from session one. The research directory is meant to be committed; it is the project's research memory. The plugin keeps no other state in the project; the distillation gate's once-per-session marker lives in the temp dir.
