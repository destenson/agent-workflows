#!/usr/bin/env bash
# PreToolUse(Edit|Write) hook: when a change targets the forked GStreamer element,
# surface the task/object-lifetime review checklist before the edit is made. The
# fork's known weak area is lifetime discipline across spawned reconnect tasks, so
# a change there should be checked against the lifetime rules first.
#
# Opt-in and explicit — no path heuristics. Does nothing unless GST_FORK_ELEMENT_PATH
# is set (in the project's .claude/settings.json env, or the shell) to the element's
# source directory. Advisory only; never blocks the edit.
set -euo pipefail

: "${GST_FORK_ELEMENT_PATH:=}"
[[ -n "$GST_FORK_ELEMENT_PATH" ]] || exit 0

input="$(cat)"
file_path="$(printf '%s' "$input" | jq -r '.tool_input.file_path // empty')"
[[ -n "$file_path" ]] || exit 0

target="$(readlink -f "$file_path" 2>/dev/null || printf '%s' "$file_path")"
base="$(readlink -f "$GST_FORK_ELEMENT_PATH" 2>/dev/null || printf '%s' "$GST_FORK_ELEMENT_PATH")"

if [[ "$target" == "$base"* ]]; then
  cat "${CLAUDE_PLUGIN_ROOT}/prompts/fork-lifetime-checklist.md" >&2
fi
exit 0
