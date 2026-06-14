---
description: Scaffold the sysadmin workflow (FLEET.md plus the INCIDENTS / CHANGELOG / RUNBOOKS journals), seeding FLEET.md from infra files in the repo and a short interview.
---

Scaffold the durable artifacts for administering this fleet, then build a real `FLEET.md` from whatever infrastructure the repo describes plus a short interview — rather than leaving an empty map. A blank FLEET.md loaded every session steers nothing; the goal is an operating map the first session can trust.

Work in four phases: resolve-and-check, discover, copy, then build FLEET.md by interview.

## 1. Resolve the directory and check what exists

The artifacts live in a dedicated **fleet directory**, not the project root — this keeps the operator `CHANGELOG.md` from colliding with a repo's release changelog and keeps the journals out of the root. The directory is `$SYSADMIN_FLEET_DIR` if that environment variable is set, otherwise `fleet/`. The session-start hook announces the resolved directory at the top of the session; use that value. Create it if it does not exist.

Check which target files exist. **Never overwrite an existing file** — it may hold a real, hand-maintained map or journal. Skip it and report it as skipped. The phases below apply only to files this run creates.

## 2. Discover the fleet from the repo

Unlike a code project, a fleet's facts live in infrastructure files, not prose. Scan the repo for the ones that actually describe hosts and systems:

- **Ansible** — `inventory*`, `hosts`, `inventory/`, group_vars/host_vars: host names, groups, connection vars.
- **Terraform** — `*.tf`, `*.tfvars` (and `terraform.tfstate` if present): instances, their roles, providers.
- **Containers / orchestration** — `docker-compose.y*ml` (service names, restart policy, ports), Kubernetes manifests (`kind:` Deployment/Statefulset/Service, namespaces), `Vagrantfile`.
- **Connection config in the repo** — an in-repo `ssh_config`, `Makefile`/deploy scripts with host references, `.kube/` contexts if committed.

Extract candidate hosts/systems with whatever each source gives: name, category (Linux/SSH · cloud instance · container/k8s · appliance), how it is reached, and known services. Note the source of each. Do **not** reach outside the repo (no reading `~/.ssh/config`, no live cloud calls) — discovery is repo-scoped; anything else comes from the interview.

If the repo describes no infrastructure at all, say so and go straight to the interview.

## 3. Copy the templates

Copy each missing file from `templates/` into the fleet directory (call it `<fleet>/`):
- `<fleet>/FLEET.md` ← `templates/FLEET.md`
- `<fleet>/INCIDENTS.md` ← `templates/INCIDENTS.md`
- `<fleet>/CHANGELOG.md` ← `templates/CHANGELOG.md`
- `<fleet>/RUNBOOKS.md` ← `templates/RUNBOOKS.md`

## 4. Build FLEET.md by interview

Seed `FLEET.md` with the discovered systems: set the fleet name, fill the **Conventions** section from discovered config locations, and add one host entry per discovered system with the fields discovery supplied (category, reach, services), each marked `(inferred — confirm)`.

Then interview the user for the fields that are not in any file and must not be guessed, because they govern what is safe to run:

- **Role and blast radius** — what each host does and what depends on it.
- **State probes (read-only)** — the commands that report each host's health, used by `/fleet-status`. Ask; do not invent commands for a host you cannot see.
- **Constraints & safety** — commands that must NOT be run on a host, maintenance windows, data that must not be touched. This is the most important field and the one with no discoverable source; never fabricate it.
- **Hosts not in the repo** — ask whether there are systems administered from here that no infra file describes, and add them.
- **Known quirks** — anything that misleads diagnosis.

Keep it efficient: confirm the discovered hosts in a batch, then collect the human-only fields. If the user does not have a field yet, leave the template placeholder so the gap is visible rather than silently blank. The journals (`INCIDENTS`, `CHANGELOG`, `RUNBOOKS`) start empty — they are appended to as work happens, not filled in now.

The fleet directory is meant to be committed — it is the fleet's durable memory. The plugin keeps no other state in the project; the Stop gate's once-per-session marker lives in the temp dir, not the working tree.

## Then explain the safety posture

So the user is not surprised by it:
- A PreToolUse(Bash) hook flags commands matching a destructive-pattern denylist with an advisory reminder (it never blocks). It is a speed bump, not a security boundary.
- Override the denylist with `SYSADMIN_DESTRUCTIVE_REGEX`; flagged commands are logged to journald (`journalctl -t sysadmin-workflow`) and, if `SYSADMIN_AUDIT_LOG` is set, appended to that file.

Report which files were created and which were skipped, which hosts were seeded from discovery (with sources), and which fields still need the user.
