#!/usr/bin/env bash
# Stop hook: a non-blocking, once-per-session reminder to keep the handoff current.
# It never blocks the stop. Stop fires at the end of every turn, so a marker keyed
# by session id limits this to one reminder per session.
#
# A non-blocking message is surfaced to the user via the systemMessage field; plain
# stdout from a Stop hook is not shown (it goes only to the debug log). The message
# differs by whether a handoff is already in play, which is a fact (file exists),
# not a guess about whether the work is "done".
set -euo pipefail

input="$(cat)"
session_id="$(printf '%s' "$input" | jq -r '.session_id // "unknown"')"

# The once-per-session marker is throwaway cross-invocation state, not project
# memory, so it lives in the temp dir — never in the working tree.
STATE_DIR="${TMPDIR:-/tmp}/handoff"
marker="${STATE_DIR}/reminded-${session_id}"

[[ -f "$marker" ]] && exit 0
mkdir -p "$STATE_DIR"
touch "$marker"

if [[ -f HANDOFF.md ]]; then
  msg="handoff: a HANDOFF.md is in play this session — update or clear it with the handoff skill as the work progresses, so the next session is not handed stale state."
  if ! grep HANDOFF.md .gitignore &>/dev/null; then
    # TODO: if the file is already committed, add a note about committing the updated version, but if it has never been committed, ask the user if they want to add it to .gitignore to avoid accidentally committing transient state.
    msg+=" (Tip: HANDOFF.md is not currently gitignored, if it has been committed before, it should be committed after updating. If it has never been committed, ask the user if they want to add it to .gitignore to avoid accidentally committing transient state.)"
  fi
else
  msg="handoff: if work is unfinished or you have discovered follow-up work, record it in HANDOFF.md with the handoff skill before wrapping up, so the next session can pick it up."
fi

jq -n --arg m "$msg" '{systemMessage: $m}'
exit 0
