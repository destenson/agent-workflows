# INCIDENTS.md — incident log

Append-only, newest first. One entry per incident. Worked as it happens (per the standing rules), not reconstructed at session end. The point is that the next person to hit the same symptom finds the last investigation instead of repeating it.

<!-- Copy the block below for each new incident. -->

## {YYYY-MM-DD} — {short title}
- **Status**: investigating | mitigated | resolved | unresolved
- **Host(s)**: which systems (from FLEET.md)
- **Symptom**: what was observed, and how it first surfaced (alert, report, probe)
- **Impact**: who/what was affected, and how badly
- **Investigation**: the read-only evidence gathered and what it ruled in/out (timestamps help)
- **Root cause**: the actual cause, once known — not the trigger, the cause
- **Resolution**: what was changed to fix it (cross-reference the CHANGELOG entry)
- **Follow-ups**: anything deferred — a runbook to write, a fix to make permanent, monitoring to add
