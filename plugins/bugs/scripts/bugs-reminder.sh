#!/usr/bin/env bash
# Stop hook: a non-blocking, once-per-session reminder to record any bug that was
# found this session but left unfixed — deferred, out of scope, or simply not yet
# tackled — in BUGS.md, so it is not lost. It never blocks the stop. Stop fires at
# the end of every turn, so a marker keyed by session id limits this to one reminder
# per session.
#
# The reminder fires only when a BUGS.md already exists: the plugin is opt-in, so it
# stays silent on projects that have not chosen to keep a bug log.
#
# A non-blocking message is surfaced to the user via the systemMessage field; plain
# stdout from a Stop hook is not shown (it goes only to the debug log).
set -euo pipefail

[[ -f BUGS.md ]] || exit 0

input="$(cat)"
session_id="$(printf '%s' "$input" | jq -r '.session_id // "unknown"')"

# The once-per-session marker is throwaway cross-invocation state, not project
# memory, so it lives in the temp dir — never in the working tree.
STATE_DIR="${TMPDIR:-/tmp}/bugs"
marker="${STATE_DIR}/reminded-${session_id}"

[[ -f "$marker" ]] && exit 0
mkdir -p "$STATE_DIR"
touch "$marker"

msg="bugs: if you found a bug this session that you did not fix (deferred or out of scope), record it in BUGS.md with the bugs skill so it is not lost. If you fixed a bug already logged there, remove its entry so the log stays current."

jq -n --arg m "$msg" '{systemMessage: $m}'
exit 0
