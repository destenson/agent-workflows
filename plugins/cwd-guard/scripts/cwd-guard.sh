#!/usr/bin/env bash
# PreToolUse(Bash) hook: deny any Bash command that hardcodes the current working
# directory — either as the absolute CWD path (or a path under it) or via a shell
# construct that expands to it ($PWD, $(pwd), ...). The shell already runs in the
# project root, so anything inside it should be addressed by a relative path; an
# absolute CWD path is a sign the agent is not doing that.
#
# A PreToolUse hook blocks by printing the deny decision to stdout and exiting 0
# (exit code 2 does NOT block a PreToolUse call). The reason is shown to the agent.
#
# Fails open: if the input cannot be parsed, the command is allowed rather than
# bricking every Bash call.
set -uo pipefail

input="$(cat)"
command="$(printf '%s' "$input" | jq -r '.tool_input.command // ""')"
cwd="$(printf '%s' "$input" | jq -r '.cwd // ""')"

[[ -z "$command" ]] && exit 0

deny=""

# 1) The absolute CWD path used as a path. A non-empty, non-root cwd only, so we do
#    not reject every absolute path. Match cwd as a whole path token — followed by a
#    separator, a quote, whitespace, a shell terminator, or the end of the command —
#    so a sibling directory like "<cwd>-other" does not false-match. The compared
#    string is quoted, so it matches literally even if cwd contains glob or regex
#    metacharacters.
if [[ -n "$cwd" && "$cwd" != "/" ]]; then
  for t in "/" '"' "'" " " "$(printf '\t')" ":" ";" ")" "|" "&" "<" ">"; do
    if [[ "$command" == *"$cwd$t"* ]]; then
      deny="the absolute working-directory path"
      break
    fi
  done
  if [[ -z "$deny" && "$command" == *"$cwd" ]]; then
    deny="the absolute working-directory path"
  fi
fi

# 2) Constructs that expand to the working directory.
if [[ -z "$deny" ]]; then
  case "$command" in
    *'$PWD'*|*'${PWD}'*|*'$(pwd)'*|*'`pwd`'*|*'$CWD'*|*'${CWD}'*)
      deny="a \$PWD / \$(pwd) expansion of the working directory" ;;
  esac
fi

[[ -z "$deny" ]] && exit 0

reason="cwd-guard blocked this command: it contains ${deny}. The shell already runs in the project root, so address files inside it by a path relative to it (e.g. \"foo/bar\", not \"${cwd}/foo/bar\" or \"\$PWD/foo/bar\"). Rewrite the command with a relative path and retry. Absolute paths outside the project (e.g. /etc, \$HOME) are fine. If you genuinely need the project root as an absolute path because the command changes directory (e.g. it \"cd\"s into a temp dir, where a relative path would no longer resolve), use \"\$(git rev-parse --show-toplevel)\" — it yields the repo root independent of the current directory and is not blocked, but don't use this tactic to get around this guard."

jq -n --arg r "$reason" '{hookSpecificOutput: {hookEventName: "PreToolUse", permissionDecision: "deny", permissionDecisionReason: $r}}'
exit 0
