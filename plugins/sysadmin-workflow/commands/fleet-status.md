---
description: Gather a read-only, point-in-time state snapshot across the fleet from FLEET.md and report what is healthy, degraded, or unreachable.
argument-hint: "[host or group, optional — defaults to whole fleet]"
---

All artifacts named below live in the fleet directory announced at session start (`$SYSADMIN_FLEET_DIR`, default `fleet/`); read them from there.

Produce a current-state snapshot of the fleet. This is read-only: run only commands that report state, never any that change it. If $ARGUMENTS names a host or group, scope to that; otherwise cover every host in FLEET.md.

If FLEET.md does not exist, stop and tell the user to run /fleet-init first — there is no fleet to survey.

For each in-scope host/system, use the **state probes declared in its FLEET.md entry**. Do not invent probes or guess at access — FLEET.md is the source of truth for how each host is reached and what "healthy" is checked by. If an entry has no state probes defined, note that as a gap to fill rather than improvising. Run probes appropriate to the host's category:
- Linux/SSH: reachability, uptime/load, disk, memory, failed units (`systemctl --failed`), the host's own declared service checks
- Cloud instance: instance/health status via the declared cloud CLI + profile, plus SSH-level checks if reachable
- Container/k8s: node and pod status in the declared context (`kubectl get nodes`, `get pods`), restart counts, pending/crashlooping workloads
- Appliance/network gear: the declared management check (reachability, interface/port status, the device's own health endpoint)

Run independent host probes in parallel where possible. Respect every safety constraint and "out of scope" note in FLEET.md.

Report a compact table — host, category, reachable?, key signals, and a verdict (healthy / degraded / unreachable / unknown) — followed by anything that warrants attention. Cross-reference open INCIDENTS.md entries: if a host you flag already has an open incident, say so rather than opening a duplicate.

This command only observes and reports. If it surfaces something broken, hand off to the troubleshooting-loop skill to work it — do not start changing state from inside a status sweep.
