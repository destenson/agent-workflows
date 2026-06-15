#!/usr/bin/env bash
# SessionStart hook: if this project is mid-hardening (a HARDENING.md exists),
# load the ledger into context and emit the session probe. Unlike a bug log, the
# hardening ledger IS the active worklist during the convert phase, so loading it
# wholesale is justified — it is bounded and shrinks as items close, not an
# ever-growing history. Silent when there is no HARDENING.md: the plugin is
# opt-in and activates only once assess-prototype has built the ledger.
#
# stdout from a SessionStart hook is added to the session context.
set -euo pipefail

[[ -f HARDENING.md ]] || exit 0

# Codex's primary plugin-root variable is PLUGIN_ROOT; Claude Code exposes only
# CLAUDE_PLUGIN_ROOT (which Codex also honors as a legacy alias). Normalize to the
# neutral name, falling back to the alias, so nothing below is tied to one harness.
PLUGIN_ROOT="${PLUGIN_ROOT:-${CLAUDE_PLUGIN_ROOT:-}}"

printf '\n===== HARDENING.md =====\n'
cat HARDENING.md

printf '\n'
cat "${PLUGIN_ROOT}/prompts/session-probe.md"
