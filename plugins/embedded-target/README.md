# embedded-target

A Claude Code plugin implementing [`embedded-target-workflow.md`](../../embedded-target-workflow.md) — the extension of the base workflow for projects whose code runs only on a remote embedded Linux target (e.g. a Jetson), where bugs are frequently environment-dependent and the scarce resource is occurrences of the triggering condition.

It is an **extension** of `agentic-workflow`, not a replacement. Install both: the base plugin handles spec discipline, journaling, and distillation; this one adds the on-device loop. Its single hook is the device analogue of the base plugin's artifact loading.

## What it does

**Hook:**
- `SessionStart` → loads `DEVICE.md` (the agent's operating map for the target) into context, the way the base plugin loads SPEC/ASSUMPTIONS/DECISIONS/LESSONS.

**Skills** (invoke when relevant): `embedded-loop` (the reproducible and instrument-and-wait debug loops), `harness-setup`, `fault-injection`, `network-capture`, `observability-setup`.

**Command:** `/device-init` scaffolds `DEVICE.md` plus the `harness/`, `faults/`, and `repros/` skeletons into the project from `templates/`.

## The templates are the deliverable

The workflow doc calls the harness scripts "sketches, to be filled in per project," because deploy mechanisms, paths, and device coordinates differ per target. So this plugin ships them as **templates** that `/device-init` copies into a project, each carrying the contract (structured exit codes, hard timeouts, idempotent reset, capture-first) with `# TODO(project)` markers where the device-specific commands go. The fault scripts (`dropout`/`lossy`/`partition`/`sweep-dropout`) are closer to working — `tc netem` / `iptables` are generic — but still need `TARGET_IF` and peer addresses.

```
templates/
├── DEVICE.md
├── harness/   env.sh build.sh deploy.sh run.sh device-reset.sh
│              collect-diag.sh backtrace.sh loop.sh  analyze/{seq-gap,interpacket-histogram}.sh
├── faults/    dropout.sh lossy.sh partition.sh sweep-dropout.sh
└── repros/    issue-template.sh all.sh
```

## Install & use

```
/plugin marketplace add /home/dennis/src/agent-workflows
/plugin install agentic-workflow     # the base; install this too
/plugin install embedded-target
# then, in a device project:
/device-init
```

Then fill in, in order: `DEVICE.md` → `harness/env.sh` (`DEVICE_SSH`, timeouts) → the `# TODO(project)` markers in the harness scripts.

## Requirements

- `bash`, `ssh`/`scp`, and `timeout` (coreutils) on the host.
- On-device: `tc`/iproute2 and `iptables` for fault injection; `tshark` for capture analysis; `gdb` and enabled cores for `backtrace.sh`.

## Deliberately not included

- The observability infrastructure (journal siphon, episodic-capture watcher, runtime log-level control, split diag `.deb`) is described in the `observability-setup` skill but not scaffolded as code — it is substantial, stateful, and project-shaped enough that a generic template would mislead. Build it from the skill guidance when a project needs it.
- A permissions allowlist isn't injected automatically; `/device-init` recommends the entries and lets you add them to `.claude/settings.json`.
