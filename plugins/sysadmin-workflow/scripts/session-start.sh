#!/usr/bin/env bash
# SessionStart hook: load the four durable artifacts into context and emit the
# session probe. One-shot context loading at session open; it does not keep
# anything live as the session runs (the standing rules do that, per turn, via
# standing-rules.sh).
#
# FLEET.md is the environment anchor — the agent's operating map for the hosts
# it administers. The journals (INCIDENTS/CHANGELOG/RUNBOOKS) carry the memory a
# future session would otherwise re-learn the hard way: what already broke, what
# was already changed, and the procedures already worked out.
#
# stdout from a SessionStart hook is added to the session context.
set -euo pipefail

PROMPTS_DIR="${CLAUDE_PLUGIN_ROOT}/prompts"

# The artifacts live in a dedicated directory (default fleet/) rather than the
# project root, so the operator CHANGELOG never collides with a repo's release
# CHANGELOG.md and the journals do not clutter the root. The location is
# overridable so a fleet managed from inside an existing repo can place them
# wherever fits. Announce the resolved directory so the slash commands — which
# are model prompts and cannot read this env var themselves — write to the same
# place this hook reads from.
FLEET_DIR="${SYSADMIN_FLEET_DIR:-fleet}"
printf '\n===== sysadmin-workflow: fleet artifacts directory = %s/ =====\n' "$FLEET_DIR"

# The durable artifacts, if this fleet has been initialized (/fleet-init). A
# directory with none of these is pre-init; the probe still tells the agent what
# to do about that.
for f in FLEET.md INCIDENTS.md CHANGELOG.md RUNBOOKS.md; do
  if [[ -f "${FLEET_DIR}/${f}" ]]; then
    printf '\n===== %s =====\n' "${FLEET_DIR}/${f}"
    cat "${FLEET_DIR}/${f}"
  fi
done

printf '\n'
cat "${PROMPTS_DIR}/session-probe.md"
