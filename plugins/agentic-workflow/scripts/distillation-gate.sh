#!/usr/bin/env bash
# Stop hook: the end-of-session distillation gate. It blocks the first stop of a
# session with the distillation prompt, then allows the next stop.
#
# This gates on a decision being *prompted*, not on content being *produced*.
# Declaring "no entries" is the frictionless exit. A gate that demanded content
# would get fed forced-completion filler — exactly the noise the journals exist
# to keep out. So after the agent has been prompted once, the next stop is
# allowed whether it wrote entries or declared empty; the honesty of that
# decision rides on the standing rules, not on this script (a shell hook cannot
# tell a real lesson from filler).
#
# A Stop hook blocks by printing {"decision":"block","reason":...} to stdout.
set -euo pipefail

input="$(cat)"
session_id="$(printf '%s' "$input" | jq -r '.session_id // "unknown"')"
stop_active="$(printf '%s' "$input" | jq -r '.stop_hook_active // false')"

# Only engage in projects that have actually adopted the workflow. A project with
# none of the durable artifacts is pre-init: there is nothing to distill into, so
# the gate stays silent rather than prompting in a project that does not use this
# workflow.
if [[ ! -f SPEC.md && ! -f ASSUMPTIONS.md && ! -f DECISIONS.md && ! -f LESSONS.md ]]; then
  exit 0
fi

# The once-per-session marker is throwaway cross-invocation state, not project
# memory, so it lives in the temp dir — never in the project. Keyed by the unique
# session id; it vanishes on reboot like the ephemeral thing it is. This plugin
# leaves nothing in the working tree but the durable artifacts themselves.
STATE_DIR="${TMPDIR:-/tmp}/agentic-workflow"
marker="${STATE_DIR}/distilled-${session_id}"

# Already prompted this session, or we are inside the block-and-continue loop the
# previous invocation started: let the stop proceed.
if [[ -f "$marker" || "$stop_active" == "true" ]]; then
  exit 0
fi

mkdir -p "$STATE_DIR"
touch "$marker"

reason="$(cat "${CLAUDE_PLUGIN_ROOT}/prompts/distillation.md")"
jq -n --arg r "$reason" '{decision: "block", reason: $r}'
exit 0
