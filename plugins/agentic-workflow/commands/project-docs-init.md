---
description: Scaffold the four durable workflow artifacts (SPEC, ASSUMPTIONS, DECISIONS, LESSONS) in the current project.
---

Initialize this project's durable workflow artifacts. For each of `SPEC.md`, `ASSUMPTIONS.md`, `DECISIONS.md`, `LESSONS.md`:

- If the file already exists in the project root, leave it untouched and report that it was skipped.
- If it does not exist, create it from the matching template at `${CLAUDE_PLUGIN_ROOT}/templates/`.

Then add `.agentic-workflow/` to the project's `.gitignore` if it isn't already there — that directory holds the distillation-gate's per-session state and should not be committed.

Report which files were created and which were skipped. Do not fill in any content beyond the templates; the design interview populates SPEC.md and the assumption audit populates ASSUMPTIONS.md.
