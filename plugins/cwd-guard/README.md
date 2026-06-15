# cwd-guard

A small standalone plugin that stops the agent from hardcoding the current working directory in Bash commands. The shell already runs in the project root, so anything inside the project should be addressed by a path relative to it — an absolute path that points back at the working directory is a sign the agent is not doing that.

## What it blocks

A `PreToolUse` hook on the `Bash` tool denies a command when it contains:

- the **absolute working-directory path** — the project root itself or any path under it (`<cwd>`, `<cwd>/...`). A boundary check means a sibling directory like `<cwd>-other` is not affected;
- a construct that **expands to** the working directory — `$PWD`, `${PWD}`, `$(pwd)`, `` `pwd` `` (and `$CWD` / `${CWD}`).

The deny is shown to the agent with a reason telling it to rewrite the command with a relative path and retry.

### The one legitimate case it also catches

The premise — "the shell runs in the project root, so use a relative path" — stops holding when a single command *changes directory* before using the path. Anchoring an absolute path to the project root and then `cd`-ing into a temp dir (`ROOT="$PWD"; ( cd "$tmp" && "$ROOT/script.sh" )`) is a correct use of `$PWD`, not the laziness the guard is aimed at, yet it trips the same rule. The guard blocks it anyway because it cannot tell the two apart, and the cost is low: the robust way to get the project root does not depend on the current directory at all — `$(git rev-parse --show-toplevel)` yields the repo root regardless of where the shell is, and is not blocked. The deny message points the agent at it. So the false positive nudges toward a strictly better construct rather than a worse one.

## What it leaves alone

- Absolute paths **outside** the project — `/etc`, `/tmp`, `$HOME`, `~/.claude`, and so on are fine; only the working directory is guarded.
- Everything when the hook input cannot be parsed: the guard fails open (allows) rather than blocking every Bash call.

## How it works

- `PreToolUse(Bash)` → reads the command and `cwd` from the hook input and, on a match, returns `permissionDecision: "deny"` with a reason. Exit-code-2 is not used because it does not block a PreToolUse call.

There is no state, no artifact, and no skill — it is purely a guard.

## Install

```
/plugin marketplace add destenson/agent-workflows
/plugin install cwd-guard
```

Under Codex: `/plugins marketplace add ./.agents/plugins/marketplace.json` then `/plugins install cwd-guard`.

## Tuning

The rule is intentionally strict — there are no exceptions, per "the agent should never use an absolute path for the working directory." If a real workflow needs the absolute path (rare), disable the plugin for that session, or relax `scripts/cwd-guard.sh`.
