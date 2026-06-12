---
name: entropy-pass
description: Run a deletion-only refactor session — remove code, consolidate duplicates, reduce special cases, with zero new behavior and all validation gates passing. Also prune the journals. Use on a cadence (e.g. every N PRPs) or when entropy has accumulated.
---

# Entropy-reduction pass

Mandate: reduce complexity with **zero new behavior**.

- **Permitted:** deleting code, consolidating duplicate or near-duplicate implementations, removing special cases by fixing root causes, collapsing speculative abstraction.
- **Forbidden:** new features, new dependencies, new abstractions, behavior changes.
- All validation gates must pass before and after.

The mandate covers the **artifacts**, not just the code — they are injected into every session, so their entropy is a context tax paid on every turn:
- Consolidate DECISIONS.md.
- Delete LESSONS.md entries that no longer apply or never prevented anything.
- Dedupe ASSUMPTIONS.md.

Append-only is the rule *within* normal sessions; the entropy pass is the one place curation happens.

Report: what was removed, what was consolidated, which special cases were eliminated, and anything you wanted to remove but couldn't — with the blocking reason recorded in LESSONS.md.
