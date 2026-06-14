---
name: fleet-onboard
description: Add a new host or system to FLEET.md through a structured intake — access, role and blast radius, services, read-only state probes, and safety constraints. Use when bringing a server, cloud instance, k8s workload, or appliance under administration, or when an existing FLEET.md entry is thin and needs filling out so the fleet map can actually be trusted.
---

# Fleet onboarding

FLEET.md is the map every session trusts before touching a live system. An incomplete entry is worse than no entry, because it invites action on missing information. This skill turns a new host into a complete, trustworthy entry — gathering the facts by read-only inspection where possible, asking the operator where it cannot.

Onboard one host/system at a time. Work through every field; do not skip a field by guessing — if a fact cannot be established, mark it explicitly as unknown so the gap is visible rather than silently filled.

## Gather, then record

For the host being onboarded, establish each of these and write it into a FLEET.md entry:

- **Category** — Linux/SSH host, cloud instance, container/k8s workload, or appliance/network gear. This determines how everything else is reached.
- **Reach** — the exact way to connect: SSH alias (confirm it resolves and connects), `kubectl --context`, cloud CLI + profile, or management URL. Verify reachability read-only before recording it; an access note that does not work is the worst kind of stale.
- **Role & blast radius** — what the host does, what depends on it, and what breaks if it goes down. This is what makes "name the host" meaningful later.
- **Services** — unit/deployment names, their restart commands, config paths, log paths. Enumerate from the host (`systemctl list-units`, `kubectl get`, etc.) rather than assuming.
- **State probes (read-only)** — the specific commands that report this host's health. These are what /fleet-status will run, so they must be concrete and read-only. Capture the ones you actually used to inspect the host.
- **Constraints & safety** — commands that must never run here, maintenance windows, data that must not be touched. Ask the operator; this cannot be inferred safely.
- **Known quirks** — anything that misleads diagnosis (clock drift, a flaky interface, slow boot). Record what you noticed during inspection.

## After recording

Confirm the new entry with the operator, especially the constraints and blast radius — the fields a wrong guess makes dangerous. If onboarding revealed the host was reached or configured differently than an existing journal assumed, note the divergence per the standing rules.
