#!/usr/bin/env bash
# PreToolUse(Bash) hook: advisory flag on destructive / state-changing commands
# against live systems. Modeled on the base workflow's complexity-gate — it
# NEVER blocks. A hard mid-task block on every ssh/systemctl strands the agent in
# awkward partial states; the operator's stated need is narration ("say in one
# sentence what and why"), not approval. So this prints a reminder to stderr,
# which the harness adds to the model's context, and the model proceeds.
#
# It fires EVERY time a matching command is seen — not once per session. Each
# execution of a destructive command is a separate risk; a block-once marker
# would silently wave through the second `rm -rf`.
#
# WHY A PATTERN MATCH (and the honesty this rule demands): detecting "destructive"
# by matching command text is a heuristic — the kind normally avoided in this
# codebase. It is used here deliberately because the alternative (the caller
# declaring per-command danger) is impossible for commands the agent itself
# composes at runtime. It is a speed bump, not a security boundary: it will miss
# novel destructive commands and false-positive on safe ones. The denylist is an
# EXPLICIT, declared regex — not inferred intent — and is fully overridable via
# SYSADMIN_DESTRUCTIVE_REGEX so the operator owns the policy.
#
# AUDIT TRAIL: every flagged command is also written out-of-band, so an
# independent operator-facing record exists even if the agent never journals it
# in-band. Default sink is journald via `logger -t sysadmin-workflow`
# (read it with: journalctl -t sysadmin-workflow). If SYSADMIN_AUDIT_LOG names a
# file, the flag is appended there too. This is an audit trail, not a barrier
# against the agent: the hook runs as the same user, so a determined agent could
# still read journald or the file. Its value is independence and persistence
# outside the repo/diff, not concealment.
set -euo pipefail

AUDIT_TAG="sysadmin-workflow"

# Default destructive-command denylist (extended regex, alternation). Override
# the whole policy with SYSADMIN_DESTRUCTIVE_REGEX. Patterns are intentionally
# conservative toward flagging; false positives cost one sentence of narration.
DEFAULT_REGEX='(\brm\b[^|;&]*[[:space:]]-[a-zA-Z]*[rf]|\bmkfs\b|\bwipefs\b|\bfdisk\b|\bparted\b|\bdd\b[^|;&]*\bof=|\bshutdown\b|\breboot\b|\bhalt\b|\bpoweroff\b|\bsystemctl[[:space:]]+(stop|disable|mask|kill)\b|\bservice[[:space:]]+[^[:space:]]+[[:space:]]+(stop|restart)\b|\bkubectl[[:space:]]+delete\b|\bdocker[[:space:]]+(rm|rmi|kill|stop|system[[:space:]]+prune|volume[[:space:]]+rm)\b|\b(DROP|TRUNCATE)[[:space:]]+(TABLE|DATABASE|SCHEMA)\b|\bchmod[[:space:]]+-R\b|\bchown[[:space:]]+-R\b|\buserdel\b|\bgroupdel\b|\biptables[[:space:]]+-F\b|\bnft[[:space:]]+flush\b|\bgit[[:space:]]+(push[^|;&]*(--force|[[:space:]]-f\b)|reset[[:space:]]+--hard|clean[[:space:]]+-[a-zA-Z]*f)|>[[:space:]]*/dev/sd|:[[:space:]]*>[[:space:]]*/)'
REGEX="${SYSADMIN_DESTRUCTIVE_REGEX:-$DEFAULT_REGEX}"

input="$(cat)"
command_str="$(printf '%s' "$input" | jq -r '.tool_input.command // empty')"

[[ -n "$command_str" ]] || exit 0

if printf '%s' "$command_str" | grep -Eq "$REGEX"; then
  # In-band: reminder the agent sees.
  printf 'SAFETY GATE: this command matches the destructive-pattern denylist and may change live-system state. Before running it, state in one sentence what it does and why. Confirm the target host and that read-only investigation is already complete. (Pattern match, not a guarantee — judge the actual command.)\n' >&2

  # Out-of-band: operator audit trail.
  ts="$(date -Is)"
  if command -v logger >/dev/null 2>&1; then
    logger -t "$AUDIT_TAG" -p user.warning -- "destructive-flag: ${command_str}" || true
  fi
  if [[ -n "${SYSADMIN_AUDIT_LOG:-}" ]]; then
    mkdir -p "$(dirname "$SYSADMIN_AUDIT_LOG")" 2>/dev/null || true
    printf '%s\tdestructive-flag\t%s\n' "$ts" "$command_str" >> "$SYSADMIN_AUDIT_LOG" || true
  fi
fi
exit 0
