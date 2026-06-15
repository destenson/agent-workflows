---
name: device-init
disable-model-invocation: true
description: Scaffold the embedded target loop in this project — DEVICE.md plus the harness/, faults/, and repros/ skeletons. Use when the user asks to initialize, scaffold, or set up the on-device build-deploy-run-collect loop for an embedded target.
---

Scaffold the on-device loop for this project from the plugin's templates at `${CLAUDE_PLUGIN_ROOT}/templates/`. Each file is copied only if it does not already exist; an existing file is never overwritten, so a half-customized `harness/` keeps its edits and only its missing files are filled in.

Run the scaffold helper, which does the copy-if-absent walk and reports `created`/`skipped` per file:

```
"${CLAUDE_PLUGIN_ROOT}/scripts/scaffold.sh" "${CLAUDE_PLUGIN_ROOT}/templates" . DEVICE.md harness faults repros
```

This copies `DEVICE.md` plus the `harness/`, `faults/`, and `repros/` trees into the project root. Report the helper's `created`/`skipped` lines to the user; if any line is `missing-template`, that is a packaging bug — surface it rather than ignoring it.

Then tell the user what they must fill in before the loop runs, in this order:
1. `DEVICE.md` — access, services, stack pins, the data-plane interface name, safety constraints.
2. `harness/env.sh` — `DEVICE_SSH` and the timeout values.
3. The `# TODO(project)` markers in `harness/build.sh`, `deploy.sh`, `device-reset.sh`, `collect-diag.sh`, `backtrace.sh`.

Recommend (do not apply silently) adding an allowlist for `harness/`, `faults/`, and `repros/` commands to the project's agent settings so the loop runs unattended while raw arbitrary ssh stays gated. Show the user the entries and let them decide.

Report which files were created and which were skipped.
