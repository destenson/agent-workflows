# FLEET.md — {fleet name}

The agent's operating map for the systems this project administers. Loaded into context at session start by the sysadmin-workflow plugin. Keep it current; a stale map sends the right fix to the wrong host.

One entry per host or system. Group by category if the fleet is large. Categories seen here: Linux/SSH hosts, cloud instances (provider API), container/k8s workloads, network/appliance gear.

## Conventions
- How hosts are named/aliased; where SSH config and kube contexts live
- Which cloud accounts/projects and CLI profiles back which hosts
- Where shared credentials/secrets come from (reference the source, never paste secrets here)

## Hosts & systems

### {host-or-system name}
- **Category**: Linux/SSH | cloud instance | container/k8s | appliance
- **Reach**: ssh alias / `kubectl --context` / cloud CLI + profile / management URL
- **Role**: what it does, what depends on it, blast radius if it goes down
- **Services**: unit/deployment names, restart commands, config paths, log paths
- **State probes (read-only)**: the commands that report this host's health (uptime, disk, failed units, pod status, etc.) — used by /fleet-status
- **Constraints & safety**: commands that must NOT be run here; maintenance windows; data that must not be touched
- **Known quirks**: anything that misleads diagnosis (clock drift, flaky interface, slow boot)

## Out of scope
- Systems explicitly NOT administered from here, so they are not touched by mistake
