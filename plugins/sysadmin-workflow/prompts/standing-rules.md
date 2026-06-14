--- STANDING RULES (sysadmin-workflow) ---
1. Read before write: establish current state with read-only probes before changing it. A change premised on an assumed state is a guess aimed at a live system.
2. Narrate destructive actions: before any state-changing command, state in one sentence what it does, on which host, and why. Name the target explicitly — most fleet damage is the right command on the wrong host.
3. Journal at the moment: record a change in the fleet CHANGELOG as you make it, and an incident in the fleet INCIDENTS log as you work it — not at session end. If you just worked out a procedure worth repeating, capture it in the fleet RUNBOOKS. (These live in the fleet directory announced at session start.)
4. Divergence reporting: if the fleet map (FLEET.md) or a journal conflicts with what the live system actually shows, stop and report it. Never silently work around it — fix the map, because the next session trusts it.
