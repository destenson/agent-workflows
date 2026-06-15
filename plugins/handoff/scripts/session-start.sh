#!/usr/bin/env bash
# SessionStart hook: if a handoff from a previous session is waiting, load it into
# context so this session resumes where the last one left off. Silent when there is
# no handoff — the plugin only speaks up when there is state to hand over.
#
# stdout from a SessionStart hook is added to the session context.
set -euo pipefail

[[ -f HANDOFF.md ]] || exit 0

# Codex's primary plugin-root variable is PLUGIN_ROOT; Claude Code exposes only
# CLAUDE_PLUGIN_ROOT (which Codex also honors as a legacy alias). Normalize to the
# neutral name, falling back to the alias, so nothing below is tied to one harness.
PLUGIN_ROOT="${PLUGIN_ROOT:-${CLAUDE_PLUGIN_ROOT:-}}"

printf '\n===== HANDOFF.md (left by a previous session) =====\n'
cat HANDOFF.md
printf '\n'
cat "${PLUGIN_ROOT}/prompts/handoff-probe.md"
