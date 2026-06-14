#!/usr/bin/env bash
# Stop hook: the end-of-shift gate. It blocks the first stop of a session with
# the end-of-shift prompt, then allows the next stop.
#
# This gates on a journaling decision being *prompted*, not on content being
# *produced*. Declaring "nothing to record" is the frictionless exit. A gate
# that demanded content would get fed forced-completion filler — exactly the
# noise the journals exist to keep out. So after the agent has been prompted
# once, the next stop is allowed whether it wrote entries or declared empty; the
# honesty of that decision rides on the standing rules, not on this script.
#
# A Stop hook blocks by printing {"decision":"block","reason":...} to stdout.
set -euo pipefail

input="$(cat)"
session_id="$(printf '%s' "$input" | jq -r '.session_id // "unknown"')"
stop_active="$(printf '%s' "$input" | jq -r '.stop_hook_active // false')"

# Only engage on a fleet that has actually adopted the workflow. A fleet dir with
# none of the durable artifacts is pre-init: there is nothing to journal into, so
# the gate stays silent rather than prompting in a repo that does not use this
# plugin. (Resolve the same dir session-start.sh uses.)
FLEET_DIR="${SYSADMIN_FLEET_DIR:-fleet}"
if [[ ! -f "${FLEET_DIR}/FLEET.md" && ! -f "${FLEET_DIR}/INCIDENTS.md" \
   && ! -f "${FLEET_DIR}/CHANGELOG.md" && ! -f "${FLEET_DIR}/RUNBOOKS.md" ]]; then
  exit 0
fi

# The once-per-session marker is throwaway cross-invocation state, not project
# memory, so it lives in the temp dir — never in the project. Keyed by the unique
# session id; it vanishes on reboot like the ephemeral thing it is. The plugin's
# only footprint in the project is the fleet/ directory.
STATE_DIR="${TMPDIR:-/tmp}/sysadmin-workflow"
marker="${STATE_DIR}/journaled-${session_id}"

# Already prompted this session, or we are inside the block-and-continue loop the
# previous invocation started: let the stop proceed.
if [[ -f "$marker" || "$stop_active" == "true" ]]; then
  exit 0
fi

mkdir -p "$STATE_DIR"
touch "$marker"

reason="$(cat "${CLAUDE_PLUGIN_ROOT}/prompts/end-of-shift.md")"
jq -n --arg r "$reason" '{decision: "block", reason: $r}'
exit 0
