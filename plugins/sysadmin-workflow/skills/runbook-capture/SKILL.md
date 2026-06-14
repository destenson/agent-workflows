---
name: runbook-capture
description: Turn a procedure just performed on the fleet into a reusable runbook in RUNBOOKS.md — trigger, preconditions, ordered steps marked read-only vs state-changing, verification, and rollback. Use right after working out a multi-step operational procedure that will be needed again, or when a recurring task is being done from memory and should be written down once.
---

# Runbook capture

A runbook earns its place by being repeatable: the next person follows it and gets the same result without re-deriving it. The moment to capture one is right after you have just done the procedure — the exact commands, the order, and the gotchas are fresh and verified. Reconstructed-from-memory runbooks are where the dangerous "step you forgot" lives.

Capture from what you actually did, not from how the procedure ought to work in theory. If you have not just performed it, you are writing aspiration, not a runbook.

## Structure each runbook

Write into RUNBOOKS.md with every field — a runbook missing its rollback or its "when not to use" is the kind that bites at 3am:

- **When to use** — the trigger situation, and explicitly when NOT to use it. A runbook applied to the wrong situation is worse than none, because it carries false confidence.
- **Preconditions** — what must be true before starting: access, host state, a maintenance window. State-changing runbooks especially need these.
- **Steps** — ordered, each a concrete command or action **with the host it runs on**. Mark each step read-only vs state-changing, so a reader knows where the irreversible part begins. Note the expected output of each step — how the operator knows it worked before moving on.
- **Verification** — how to confirm the whole procedure succeeded, end to end.
- **Rollback** — how to back out if a step fails partway. A multi-step change with no rollback is a one-way door; if there genuinely is none, say so loudly.
- **Related** — the incident this came from, the kind of change it produces.

## After capture

Dry-read the runbook as if you were a colleague who has never done this: could they follow it without you? Anything that requires unstated knowledge is a missing precondition or an under-specified step — fix it now while the procedure is fresh.
