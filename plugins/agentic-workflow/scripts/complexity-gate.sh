#!/usr/bin/env bash
# PreToolUse(Edit|Write) hook: advance notice when the target file already
# exceeds the complexity budget. Advisory only — it never blocks the edit.
# Enforcement belongs in CI; a hard mid-task block strands the agent in awkward
# partial states. The point is to surface the refactor-or-split decision early.
#
# The budget is a line cap. Counting lines in this gate is the gate's whole job;
# override the default with COMPLEXITY_BUDGET_LINES.
set -euo pipefail

CAP="${COMPLEXITY_BUDGET_LINES:-1000}"

input="$(cat)"
file_path="$(printf '%s' "$input" | jq -r '.tool_input.file_path // empty')"

# No path, or a file that does not exist yet (a fresh Write) — nothing to warn about.
[[ -n "$file_path" && -f "$file_path" ]] || exit 0

lines="$(wc -l < "$file_path")"
if (( lines > CAP )); then
  printf 'COMPLEXITY BUDGET: %s is %d lines (cap %d). Consider splitting or consolidating before adding to it; a cap violation is a refactor-or-split decision point.\n' \
    "$file_path" "$lines" "$CAP" >&2
fi
exit 0
