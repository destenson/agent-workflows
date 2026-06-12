---
description: Scaffold the embedded target loop in this project — DEVICE.md plus the harness/, faults/, and repros/ skeletons.
---

Scaffold the on-device loop for this project from the plugin's templates at `${CLAUDE_PLUGIN_ROOT}/templates/`. For each target below, copy it from the template only if it does not already exist; never overwrite an existing file — report it as skipped instead.

Copy into the project root:
- `DEVICE.md` ← `templates/DEVICE.md`
- `harness/` ← `templates/harness/` (env.sh, build.sh, deploy.sh, run.sh, device-reset.sh, collect-diag.sh, backtrace.sh, loop.sh, and analyze/)
- `faults/` ← `templates/faults/` (dropout.sh, lossy.sh, partition.sh, sweep-dropout.sh)
- `repros/` ← `templates/repros/` (issue-template.sh, all.sh)

After copying, `chmod +x` the copied `.sh` files.

Then tell the user what they must fill in before the loop runs, in this order:
1. `DEVICE.md` — access, services, stack pins, the data-plane interface name, safety constraints.
2. `harness/env.sh` — `DEVICE_SSH` and the timeout values.
3. The `# TODO(project)` markers in `harness/build.sh`, `deploy.sh`, `device-reset.sh`, `collect-diag.sh`, `backtrace.sh`.

Recommend (do not apply silently) adding an allowlist for `harness/`, `faults/`, and `repros/` commands to the project's `.claude/settings.json` so the loop runs unattended while raw arbitrary ssh stays gated. Show the user the entries and let them decide.

Report which files were created and which were skipped.
