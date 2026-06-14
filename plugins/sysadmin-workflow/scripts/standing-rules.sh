#!/usr/bin/env bash
# UserPromptSubmit hook: re-inject the ops standing rules on every user turn,
# before the model sees the prompt. Per-turn injection counters the decay that
# buries a once-per-session SessionStart injection as context fills. The rules
# are kept short deliberately — they are paid for on every turn.
#
# stdout from a UserPromptSubmit hook is added to the model's context.
set -euo pipefail
cat "${CLAUDE_PLUGIN_ROOT}/prompts/standing-rules.md"
