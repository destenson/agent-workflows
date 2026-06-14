---
description: Scaffold the sysadmin workflow in this project — FLEET.md plus the INCIDENTS / CHANGELOG / RUNBOOKS journals.
---

Scaffold the durable artifacts for administering this fleet from the plugin's templates at `${CLAUDE_PLUGIN_ROOT}/templates/`. For each file below, copy it from the template only if it does not already exist; never overwrite an existing file — report it as skipped instead.

The artifacts live in a dedicated **fleet directory**, not the project root — this keeps the operator `CHANGELOG.md` from colliding with a repo's release changelog and keeps the journals out of the root. The directory is `$SYSADMIN_FLEET_DIR` if that environment variable is set, otherwise `fleet/`. The session-start hook announces the resolved directory at the top of the session; use that value. Create the directory if it does not exist.

Copy into the fleet directory (call it `<fleet>/`):
- `<fleet>/FLEET.md` ← `templates/FLEET.md`
- `<fleet>/INCIDENTS.md` ← `templates/INCIDENTS.md`
- `<fleet>/CHANGELOG.md` ← `templates/CHANGELOG.md`
- `<fleet>/RUNBOOKS.md` ← `templates/RUNBOOKS.md`

After copying, tell the user what to fill in before administering the fleet, in this order:
1. `<fleet>/FLEET.md` — one entry per host/system: category, how it is reached, role and blast radius, services, the read-only state probes for that host, and any safety constraints. This is the map every session trusts.
2. The journals start empty — they are appended to as work happens, not filled in now.

The fleet directory is meant to be committed — it is the fleet's durable memory. The plugin keeps no other state in the project; the Stop gate's once-per-session marker lives in the temp dir, not the working tree.

Then explain the safety posture so the user is not surprised by it:
- A PreToolUse(Bash) hook flags commands matching a destructive-pattern denylist with an advisory reminder (it never blocks). It is a speed bump, not a security boundary.
- Override the denylist with `SYSADMIN_DESTRUCTIVE_REGEX`; flagged commands are logged to journald (`journalctl -t sysadmin-workflow`) and, if `SYSADMIN_AUDIT_LOG` is set, appended to that file.

Report which files were created and which were skipped.
