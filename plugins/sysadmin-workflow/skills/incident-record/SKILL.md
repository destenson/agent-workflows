---
name: incident-record
description: Capture an incident into INCIDENTS.md with the full structure — symptom, impact, investigation evidence, root cause, resolution, follow-ups. Use when something has broken or is breaking on the fleet and the work needs a durable record, or when closing out an incident worked during a session so the next person finds the investigation instead of repeating it.
---

# Incident recording

An incident record exists so the next person to see the same symptom finds the last investigation instead of starting over. That payoff only happens if the record captures the *reasoning and evidence*, not just "fixed it." This skill imposes the structure that makes a record worth reading later.

Records are worked as the incident unfolds (per the standing rules), not reconstructed at the end — investigation notes written live are accurate; ones written from memory at session close are lossy.

## Open the record when work starts

Add an entry to INCIDENTS.md (newest first) the moment an incident is being worked, with status `investigating`:

- **Title & date** — short, searchable; the symptom, not the cause (the cause is not known yet).
- **Host(s)** — which systems, named from FLEET.md.
- **Symptom** — what was observed and how it surfaced (alert, user report, a /fleet-status probe). Concrete: error text, timestamps, the failing check.
- **Impact** — who/what is affected and how badly. This sets the urgency and the acceptable-risk bar for fixes.

## Fill as the investigation proceeds

- **Investigation** — the read-only evidence gathered, and crucially what each piece ruled in or out. Timestamps matter; an incident is a timeline. This is the section a future reader mines.
- Update **status** as it moves: `investigating` → `mitigated` → `resolved` (or `unresolved`).

## Close the record

- **Root cause** — the actual cause, distinguished from the trigger. "Ran out of disk" is a trigger; "log rotation was masked after the last upgrade" is a cause. Resolving the trigger without the cause means it recurs.
- **Resolution** — what was changed to fix it; cross-reference the CHANGELOG.md entry rather than duplicating it.
- **Follow-ups** — anything deferred: a permanent fix, a runbook to write (hand to runbook-capture), monitoring to add. An incident with recurring potential and no follow-up is a future repeat.

If the incident is left unresolved at session end, record the current state and the next thing to try, explicitly — an open incident handed off blind costs the next session the whole investigation.
