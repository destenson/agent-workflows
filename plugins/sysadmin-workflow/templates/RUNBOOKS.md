# RUNBOOKS.md — procedures

Reusable procedures worked out on this fleet. A runbook earns its place by being repeatable: the next person follows the steps and gets the same result without re-deriving them. Capture one when you finish a procedure you (or a future session) will need again.

<!-- Copy the block below for each runbook. -->

## {runbook name}
- **When to use**: the trigger — the situation this procedure is for, and when NOT to use it
- **Preconditions**: what must be true first (access, host state, maintenance window)
- **Steps**:
  1. Each step as a concrete command or action, with the host it runs on
  2. Mark steps that change state (vs. read-only checks)
  3. Note expected output / how to know the step worked
- **Verification**: how to confirm the whole procedure succeeded
- **Rollback**: how to back out if a step fails partway
- **Related**: incidents this came from, changes it produces
