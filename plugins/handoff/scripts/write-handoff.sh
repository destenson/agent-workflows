#!/usr/bin/env bash
# Write HANDOFF.md from a JSON payload on stdin. Refuses to overwrite an
# existing HANDOFF.md so an in-progress handoff is never clobbered; edit
# that file directly instead.
#
# Usage:
#   echo '<json>' | bash "${CLAUDE_PLUGIN_ROOT}/scripts/write-handoff.sh"
#
# JSON schema (all fields optional except as_of and status):
#   as_of          - string: date (and HEAD commit if useful)
#   status         - string: one-line status summary
#   done           - array of strings
#   in_progress    - array of strings
#   discovered     - array of strings
#   next_steps     - array of strings  (rendered as numbered list)
#   open_questions - array of strings
#   gotchas        - array of strings
set -euo pipefail

if [[ -e HANDOFF.md ]]; then
  echo "HANDOFF.md already exists; refusing to overwrite it." >&2
  echo "Edit HANDOFF.md directly to update the handoff, or delete it first to start fresh." >&2
  exit 1
fi

payload="$(cat)"

as_of="$(printf '%s' "$payload" | jq -r '.as_of // "unknown"')"
status_line="$(printf '%s' "$payload" | jq -r '.status // "(no status provided)"')"

# Renders an array field as a bullet list; emits "- (none)" when empty.
render_list() {
  local key="$1"
  local items
  items="$(printf '%s' "$payload" | jq -r --arg k "$key" '.[$k][]? | "- \(.)"')"
  if [[ -z "$items" ]]; then
    echo "- (none)"
  else
    printf '%s\n' "$items"
  fi
}

# Renders an array field as a numbered list; emits "1. (none)" when empty.
render_numbered() {
  local key="$1"
  local items
  items="$(printf '%s' "$payload" | jq -r --arg k "$key" '[.[$k][]?] | to_entries[] | "\(.key + 1). \(.value)"')"
  if [[ -z "$items" ]]; then
    echo "1. (none)"
  else
    printf '%s\n' "$items"
  fi
}

cat > HANDOFF.md <<HANDOFF
# Handoff

_Left by the previous session for the next one. A single rolling file: keep it current, and clear it (or reset to this empty template) once the work is fully picked up. Local working state by default — not committed unless you choose to._

**As of:** ${as_of}
**Status in one line:** ${status_line}

## Done
$(render_list done)

## In progress
$(render_list in_progress)

## Discovered — not yet started
$(render_list discovered)

## Next steps
$(render_numbered next_steps)

## Open questions / decisions pending
$(render_list open_questions)

## Gotchas
$(render_list gotchas)
HANDOFF

echo "HANDOFF.md written."

# Warn if HANDOFF.md is not gitignored and this is a git repo.
if git rev-parse --git-dir > /dev/null 2>&1; then
  if ! git check-ignore -q HANDOFF.md 2>/dev/null; then
    echo "NOTE: HANDOFF.md is not gitignored. Add it to .gitignore if you want it to stay local."
  fi
fi
