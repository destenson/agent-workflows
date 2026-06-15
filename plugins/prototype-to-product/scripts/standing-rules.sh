#!/usr/bin/env bash
# UserPromptSubmit hook: re-inject the hardening standing rules on every user turn.
# Per-turn injection counters the decay that buries a once-per-session SessionStart
# injection as context fills. Gated on HARDENING.md existing so it stays silent
# until the project has adopted the workflow — and so a project that only enabled
# this plugin in passing pays nothing on every turn.
#
# stdout from a UserPromptSubmit hook is added to the model's context.
set -euo pipefail

[[ -f HARDENING.md ]] || exit 0

PLUGIN_ROOT="${PLUGIN_ROOT:-${CLAUDE_PLUGIN_ROOT:-}}"
cat "${PLUGIN_ROOT}/prompts/standing-rules.md"
