---
name: bug-investigation
description: Investigate observed wrong behavior, reproduce-first, and record the understanding (ruled-out hypotheses, root cause) — not just the diff. Use when starting any non-trivial bug, as distinct from implementing a spec item.
---

# Bug investigation

A bug is not a PRP. Implementation starts from a spec item and ends in a diff; a bug investigation starts from observed wrong behavior and ends — sometimes — somewhere other than a diff.

**Reproduce first.** Produce a check that fails *because of this bug* before changing anything. A plausible-looking patch with no failing repro is a guess, not a fix. Then localize, fix, and confirm the same repro passes — end-to-end, repeatedly, under the real triggering condition for environment- or timing-dependent bugs, not once by hand.

Three things may outlast this session; only one is the diff. Record them in proportion to what you learned, not the size of the fix:
1. Every hypothesis you ruled out and why → LESSONS.md. These are exactly the dead ends a future session would otherwise repeat.
2. The root cause, especially if it explains other symptoms → DECISIONS.md, even when nothing was decided to build, because it changes how the next reader interprets those symptoms.

**Attempt budget.** If after ~2–3 attempts the fix keeps growing into a workaround on top of earlier workarounds, stop. That is evidence the implementation is structurally wrong, not that you need a cleverer patch. Write down what the failures imply about the structure and hand off the patch-or-rewrite decision to a fresh session rather than forcing another layer.
