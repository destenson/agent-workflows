---
name: project-docs-init
disable-model-invocation: true
description: Scaffold the four durable workflow artifacts (SPEC, ASSUMPTIONS, DECISIONS, LESSONS), seeding the SPEC framing from the project where it can be discovered. Use when the user asks to initialize, scaffold, or set up the project's durable workflow docs.
---

Initialize this project's durable workflow artifacts and seed the SPEC's framing from what the project already tells you, rather than leaving raw placeholders. Keep this light: the deeper SPEC sections and the assumptions are owned by dedicated skills (see below), and this must not duplicate them.

Work in three phases: check, discover-and-seed, hand off.

## 1. Check what exists

For each of `SPEC.md`, `ASSUMPTIONS.md`, `DECISIONS.md`, `LESSONS.md` in the project root:

- If the file already exists, leave it untouched and report that it was skipped. **Never overwrite.**
- If it does not exist, create it from the matching template at `${CLAUDE_PLUGIN_ROOT}/templates/`.

## 2. Discover and seed the SPEC framing

For a newly created `SPEC.md` only, do a quick orientation pass — a few tool calls, not a full audit — and fill the parts that are genuinely discoverable:

- `README*`, `ABOUT*`, `docs/`, a top-level `*.md`, and package metadata (`pyproject.toml`, `package.json`, `Cargo.toml`) for the project name and one-line purpose.
- The code structure at a high level and the dependency/runtime info for the environment.

Fill only these fields:
- Replace `{project}` with the real name.
- **Problem** — what is being built and who has the problem, from the README/description.
- **Environment facts** — language, runtime, key dependencies, integration points, and scale if stated.

Mark every value you inferred with a trailing `(inferred — confirm)`. Leave the judgment-heavy sections — **Success criteria**, **Hard constraints**, **Non-goals**, **Premises this spec relies on** — as their original placeholder text. Those are not lying around in a repo, and guessing them manufactures commitments nobody made.

Do **not** populate `ASSUMPTIONS.md` — it stays as the template. `DECISIONS.md` and `LESSONS.md` are append-only journals and start empty.

## 3. Hand off to the skills that own the rest

This deliberately seeds only the framing. The fuller artifacts come from dedicated skills, and that division of labor is intentional — point the user at them:

- Run **`design-interview`** to populate the rest of `SPEC.md` (success criteria, constraints, non-goals, premises) properly.
- Run **`assumption-audit`** to turn the SPEC's premises into `ASSUMPTIONS.md`.

Report which files were created and which were skipped, what you seeded into `SPEC.md` and the source of each inferred value, and the two skills to run next.
