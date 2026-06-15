--- SESSION PROBE (sysadmin-workflow) ---

The artifacts above are this fleet's memory: FLEET.md (the hosts and how to reach them), INCIDENTS.md (what has broken and why), CHANGELOG.md (what has been changed), RUNBOOKS.md (worked-out procedures). If none were shown, this fleet is not yet initialized — run fleet-init skill before administering it.

Before running anything against a live system, summarize:
1. The relevant fleet state — which hosts/systems are in scope and how they are reached (from FLEET.md).
2. Open incidents and recent changes that bear on what you are about to do (from INCIDENTS.md / CHANGELOG.md).
3. The current task, and whether a runbook already covers it (from RUNBOOKS.md).
4. What you do NOT yet know about current state, and the read-only probes you will run first to find out.

Do not change live-system state until this summary is done and read-only investigation has established what you are actually working with. Administering a fleet from a stale or assumed picture is how the wrong host gets the right fix.
