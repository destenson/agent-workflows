---
name: add-server
disable-model-invocation: true
description: Add a system to the fleet — either onboard an existing host, or provision a new one (e.g. a Docker container) and then onboard it — recording it in FLEET.md. Use when the user asks to add a server, onboard a host, or provision and register a new system.
---

All artifacts named below live in the fleet directory announced at session start (`$SYSADMIN_FLEET_DIR`, default `fleet/`); read and write them there.

Add a host or system to the fleet and record it in FLEET.md. If FLEET.md does not exist, stop and tell the user to run fleet-init first.

Determine the mode (onboard an **existing** host, or provision a **new** one) from what the user said, or ask if it is not clear. The user may also have named the host.

## Existing host
Onboard a host that already exists. Use the **fleet-onboard skill**: gather access, role and blast radius, services, read-only state probes, and safety constraints — verifying reachability read-only before recording — and write a complete FLEET.md entry. No CHANGELOG entry is needed; nothing was changed, only mapped.

## New host (provision, then onboard)
Provision a new system, then onboard it.

1. **Determine the provisioning method — do not guess it.** Take it from what the user said, or from the conventions section of FLEET.md, or ask the user. The method may be a Docker container, a `docker compose` service, a cloud instance via the relevant CLI, a VM, or anything else; this is tool-agnostic and does not assume Docker.
2. **Provision it**, narrating the action in one sentence first (what you are creating, where, why). Creation is state-changing even though it is not destructive, so treat it with the same care as any fleet change.
3. **Verify it is up and reachable** with read-only probes before recording anything — the same reachability check the fleet-onboard skill requires. A FLEET.md entry for a host you have not actually reached is stale on arrival.
4. **Onboard it** with the fleet-onboard skill: write the full FLEET.md entry, including the read-only state probes appropriate to how it was built (for a container: `docker ps`/`docker inspect`/exec-based checks; for a cloud instance: the provider's status check; etc.).
5. **Record a CHANGELOG.md entry** — this created infrastructure: what was created, how (the exact provisioning command), why, and how to tear it down (the revert).

After either mode, show the user the new FLEET.md entry and confirm the constraints and blast radius — the fields a wrong value makes dangerous later.
