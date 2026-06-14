# sysadmin-workflow

A Claude Code plugin for administering and troubleshooting remote systems — Linux/SSH hosts, cloud instances, container/k8s workloads, and network/appliance gear — with durable fleet memory and a safety posture suited to acting on live production state.

Unlike `embedded-target`, this plugin is **self-contained**: it does not extend `agentic-workflow` and does not require it. Its spine mirrors the base plugin's machinery (artifact loading, per-turn standing rules, a session-exit gate) but is built around an environment that is *operated continuously* rather than a project that is *built and shipped*. The durable artifacts are a fleet map and three operational journals, not a spec.

## The model

Administering a fleet is not a project with an end, so the memory it needs is different from a spec. Four artifacts carry it across sessions, kept in a dedicated **fleet directory** (`fleet/` by default — see below):

- **`FLEET.md`** — the operating map: every host/system, how it is reached, its role and blast radius, its services, its read-only health probes, and its safety constraints. The agent reads this before touching anything.
- **`INCIDENTS.md`** — append-only incident log: symptom, investigation evidence, root cause, resolution. So the next person finds the last investigation instead of repeating it.
- **`CHANGELOG.md`** — append-only change record: what changed on which host, when, why, how to revert. So "it worked last week" is answerable.
- **`RUNBOOKS.md`** — reusable procedures worked out on this fleet.

**Why a directory, not the project root.** The sibling plugins (`agentic-workflow`, `embedded-target`) keep their durable artifacts in the repo root. This one deliberately does not: an operator change record named `CHANGELOG.md` in the root would collide with the near-universal release-changelog convention — the hooks would silently load the wrong file. So the artifacts live together in `fleet/`, overridable via `SYSADMIN_FLEET_DIR`. The directory is meant to be committed; it is the fleet's memory. `SessionStart` announces the resolved path so the slash commands (which are model prompts and cannot read the env var) write to the same place the hooks read from.

## What it does

**Hooks:**
- `SessionStart` → loads the four artifacts into context and emits a session probe that forces a fleet-state summary before any live action.
- `UserPromptSubmit` → re-injects the ops standing rules every turn (read before write; narrate destructive actions and name the host; journal as you go; report divergence).
- `PreToolUse(Bash)` → the **safety gate** (see below).
- `Stop` → the end-of-shift gate: blocks the first stop once, prompting to record changes/incidents/runbooks before the session ends. Its once-per-session marker lives in the temp dir (`${TMPDIR:-/tmp}/sysadmin-workflow/`), never in the project; a pre-init guard keeps it silent in a repo that has not run `/fleet-init`.

**Commands:**
- `/fleet-init` — scaffolds the four artifacts into the fleet directory from `templates/`.
- `/fleet-status [host|group]` — read-only, point-in-time state snapshot across the fleet, using the probes declared per host in `FLEET.md`. Observes and reports only; hands off to troubleshooting if it finds something broken.
- `/add-server [name] [existing|new]` — onboard an existing host into `FLEET.md`, or provision a new one (Docker container, cloud instance, …; provisioning method is taken from your input or `FLEET.md` conventions, never guessed) and then onboard it, recording a `CHANGELOG` entry for the creation.
- `/incident [title]` — open a structured incident in `INCIDENTS.md` (or continue an open one) and work it through the troubleshooting loop.
- `/runbook [name]` — list runbooks, or execute a named one step-by-step with each state-changing step narrated, verified, and recorded.

**Skills** (invoke when relevant): `troubleshooting-loop` (the diagnose→probe→hypothesize→change→verify→record loop against live systems), `fleet-onboard` (structured intake of a new host into `FLEET.md`), `incident-record` (structured incident capture), `runbook-capture` (turn a just-performed procedure into a reusable runbook).

## The safety gate

The `PreToolUse(Bash)` hook flags commands matching a destructive-pattern denylist (`rm -rf`, `mkfs`/`dd`, `systemctl stop/disable`, `kubectl delete`, `shutdown`/`reboot`, `DROP`/`TRUNCATE`, force-push, etc.) with an advisory reminder to state what/why and confirm the host first.

It is **advisory and fires every time** — it never blocks. Each execution of a destructive command is a separate risk, so flagging every occurrence is the point; a once-per-session block would wave through the second `rm -rf`. The reminder goes to the model's context; the command still runs.

**It is a speed bump, not a security boundary.** Detecting "destructive" by matching command text is a pattern match: it will miss novel destructive commands and false-positive on safe ones. The denylist is an explicit, declared regex — override the whole policy with `SYSADMIN_DESTRUCTIVE_REGEX`. "Read-only-first" itself is *not* enforced by this hook (a hook cannot know an investigation happened); that discipline lives in the `troubleshooting-loop` skill and the standing rules.

**Audit trail.** Every flagged command is also written out-of-band: to journald via `logger -t sysadmin-workflow` (read with `journalctl -t sysadmin-workflow`), and, if `SYSADMIN_AUDIT_LOG` names a file, appended there too. This gives an operator an independent, persistent record outside the repo and the conversation — but it is *not* concealed from the agent: the hook runs as the same user, so a determined agent could read it. Its value is independence and persistence, not secrecy.

## Install & use

```
/plugin marketplace add /home/dennis/src/agent-workflows
/plugin install sysadmin-workflow
# then, in a project that administers a fleet:
/fleet-init
# fill in fleet/FLEET.md (one entry per host: reach, role, services, state probes, constraints), then:
/fleet-status
```

## Requirements

- `bash` and `jq` on the host (the hooks parse tool input with `jq`).
- `logger` (util-linux) for the journald audit trail; if absent, set `SYSADMIN_AUDIT_LOG` to a file instead.
- Whatever each host's category needs to be reached: `ssh` for Linux hosts, the relevant cloud CLI, `kubectl`, etc. — declared per host in `FLEET.md`, not assumed by the plugin.

## Configuration (environment variables)

- `SYSADMIN_FLEET_DIR` — directory holding the four artifacts (default `fleet/`). Set this once in the environment Claude Code runs in; both the hooks and the commands resolve it the same way.
- `SYSADMIN_DESTRUCTIVE_REGEX` — replace the default denylist with your own extended-regex policy.
- `SYSADMIN_AUDIT_LOG` — also append flagged commands to this file (outside the working tree is recommended).

## Scope

This plugin covers the **administration and troubleshooting** of a running fleet — the reactive, incident-driven, per-host work. The proactive, service-level cadence of day-to-day operations (dashboards, maintenance windows, on-call handoff, capacity) is deliberately left out; it is a separate concern that may become its own plugin once this substrate is exercised.
