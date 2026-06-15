#!/usr/bin/env bash
# SessionStart hook: if the project keeps a BUGS.md, note that it exists and state the
# standing instruction — record any bug found-but-not-fixed there. It does NOT print the
# file's contents: a durable bug log grows, and loading it wholesale every session is
# context bloat. The agent can read BUGS.md on demand when it actually needs the open
# list. Silent when there is no BUGS.md: the plugin is opt-in and activates only once the
# project has chosen to keep a bug log.
#
# stdout from a SessionStart hook is added to the session context.
set -euo pipefail

[[ -f BUGS.md ]] || exit 0

# Codex's primary plugin-root variable is PLUGIN_ROOT; Claude Code exposes only
# CLAUDE_PLUGIN_ROOT (which Codex also honors as a legacy alias). Normalize to the
# neutral name, falling back to the alias, so nothing below is tied to one harness.
PLUGIN_ROOT="${PLUGIN_ROOT:-${CLAUDE_PLUGIN_ROOT:-}}"

cat "${PLUGIN_ROOT}/prompts/bugs-probe.md"
