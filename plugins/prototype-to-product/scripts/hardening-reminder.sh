#!/usr/bin/env bash
# Stop hook: a non-blocking, once-per-session reminder to keep HARDENING.md current
# — remove items closed this session, and record any new prototype-grade gap
# discovered this session — so the ledger does not drift from the code. It never blocks the
# stop. Stop fires at the end of every turn, so a marker keyed by session id limits
# this to one reminder per session.
#
# Fires only when a HARDENING.md already exists: the plugin is opt-in, so it stays
# silent on projects that are not mid-hardening.
#
# A non-blocking message is surfaced to the user via the systemMessage field; plain
# stdout from a Stop hook is not shown (it goes only to the debug log).
set -euo pipefail

[[ -f HARDENING.md ]] || exit 0

input="$(cat)"
session_id="$(printf '%s' "$input" | jq -r '.session_id // "unknown"')"

# The once-per-session marker is throwaway cross-invocation state, not project
# memory, so it lives in the temp dir — never in the working tree.
STATE_DIR="${TMPDIR:-/tmp}/prototype-to-product"
marker="${STATE_DIR}/reminded-${session_id}"

[[ -f "$marker" ]] && exit 0
mkdir -p "$STATE_DIR"
touch "$marker"

msg="prototype-to-product: keep HARDENING.md current — remove any hardening item you closed this session, and add any new prototype-grade gap you found (with the assess-prototype or convert-prototype skill) so the ledger matches the code."

jq -n --arg m "$msg" '{systemMessage: $m}'
exit 0
