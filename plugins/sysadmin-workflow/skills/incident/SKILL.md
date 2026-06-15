---
name: incident
description: Open a new incident in INCIDENTS.md (or update an open one) with the full structure, then work it through the troubleshooting loop. Use when the user reports a problem, an outage, or a failing system, or asks to open or continue an incident.
---

All artifacts named below live in the fleet directory announced at session start (`$SYSADMIN_FLEET_DIR`, default `fleet/`); read and write them there.

Open or continue an incident. If FLEET.md does not exist, stop and tell the user to run fleet-init first.

Take the symptom title (or the title of an already-open incident) from what the user provided. Read INCIDENTS.md and decide which case applies:

**Continuing an open incident** — if what the user gave matches an existing entry whose status is not `resolved`: load it, summarize its current state and what has been ruled in/out so far, and pick up the investigation from there. Do not open a duplicate.

**Opening a new incident** — otherwise: use the incident-record skill to add a new entry (newest first, status `investigating`) with title, date, affected host(s) named from FLEET.md, the symptom (concrete — error text, timestamps, the failing check), and impact. Capture what is known now; the cause is not known yet, so do not write one.

Then work the incident with the troubleshooting-loop skill: establish current state with read-only probes before any change, narrate and name the host on every state-changing command, and update the incident record (and CHANGELOG.md) as the work proceeds — not at the end.

If the user gave no symptom, ask for it and which host(s) it affects before opening anything.
