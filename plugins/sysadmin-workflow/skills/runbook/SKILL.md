---
name: runbook
disable-model-invocation: true
description: List the runbooks in RUNBOOKS.md, or execute a named one step-by-step with each state-changing step narrated and verified. Use when the user asks to list runbooks or to run/execute a named runbook procedure.
---

All artifacts named below live in the fleet directory announced at session start (`$SYSADMIN_FLEET_DIR`, default `fleet/`); read and write them there.

If RUNBOOKS.md does not exist, stop and tell the user to run fleet-init first.

**No runbook named** — list every runbook in RUNBOOKS.md: name and its "when to use" line, so the user can pick. Do not run anything.

**A runbook name given** — locate it in RUNBOOKS.md. If no exact match, list the closest names and stop; do not run a runbook the user did not ask for.

Once located, execute it deliberately:
1. Check its **preconditions** first. If any is not met (access, host state, maintenance window), stop and report which — do not start a procedure whose preconditions fail partway.
2. Confirm the **target host(s)** with the user before the first state-changing step. A runbook run against the wrong host is the same hazard as any other change.
3. Work the **steps in order**. For each, run it on the host the runbook names. Before each step marked state-changing, narrate it in one sentence (the safety gate will flag destructive ones — that is expected). After each step, confirm the expected output before moving on; if a step does not produce it, stop rather than pressing forward on a broken assumption.
4. Run the **verification** at the end and report whether the whole procedure succeeded.
5. If a step fails partway, follow the runbook's **rollback**. Record what happened in CHANGELOG.md (and open an incident with the incident skill if it left the host in a bad state).

Record the run's state-changing steps in CHANGELOG.md as you go. If the runbook proved wrong or incomplete during the run, fix it in RUNBOOKS.md (or use runbook-capture) while it is fresh — per the divergence standing rule, a runbook that misled is a map to correct, not to work around.
