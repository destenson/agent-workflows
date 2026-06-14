#!/usr/bin/env bash
# Stop hook: the board-decision gate. It nudges exactly once when a board review
# reached a decision this session that has not yet been written to BOARD.md.
#
# The gate cannot see what happened in-session on its own, so the handshake is
# explicit and lives in a single marker file: /board-review drops the marker when
# it produces a verdict, and recording the decision to BOARD.md removes it. The
# gate fires only while the marker exists, and removes the marker when it fires —
# so it nudges at most once and never nags a later session. A clean run that
# records its decision immediately clears the marker itself and the gate stays
# silent.
#
# A Stop hook blocks by printing {"decision":"block","reason":...} to stdout.
set -euo pipefail

# Only engage in projects that have adopted this workflow. With no BOARD.md there
# is nothing to record into, so the gate stays silent in projects that do not use
# the plugin.
if [[ ! -f governance/BOARD.md ]]; then
  exit 0
fi

# The pending-decision marker is throwaway cross-invocation state, not project
# memory, so it lives in the temp dir — never in the working tree.
STATE_DIR="${TMPDIR:-/tmp}/c-suite"
marker="${STATE_DIR}/pending-decision"

# No unrecorded decision pending: let the stop proceed.
if [[ ! -f "$marker" ]]; then
  exit 0
fi

# A decision is pending. Nudge once, then remove the marker so the next stop is
# allowed whether or not the agent recorded it — the honesty of that recording
# rides on the board-review skill's instructions, not on this script.
rm -f "$marker"

reason="$(cat "${CLAUDE_PLUGIN_ROOT}/prompts/board-distillation.md")"
jq -n --arg r "$reason" '{decision: "block", reason: $r}'
exit 0
