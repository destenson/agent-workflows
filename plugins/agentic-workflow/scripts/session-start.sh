#!/usr/bin/env bash
# SessionStart hook: load the four durable artifacts into context and emit the
# session probe. This is one-shot context loading at session open; it does not
# keep anything live as the session runs (the standing rules do that, per turn,
# via standing-rules.sh).
#
# stdout from a SessionStart hook is added to the session context.
set -euo pipefail

PROMPTS_DIR="${CLAUDE_PLUGIN_ROOT}/prompts"

# The durable artifacts, if this project has been initialized (/project-docs-init).
# A project with none of these is pre-init; the probe still tells the agent what
# to do about that.
for f in SPEC.md ASSUMPTIONS.md DECISIONS.md LESSONS.md; do
  if [[ -f "$f" ]]; then
    printf '\n===== %s =====\n' "$f"
    cat "$f"
  fi
done

printf '\n'
cat "${PROMPTS_DIR}/session-probe.md"
