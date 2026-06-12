---
name: session-retrospective
description: Run the end-of-session distillation by hand — capture dead ends in LESSONS.md and non-obvious choices in DECISIONS.md. Use before wrapping up a session, or when the Stop-hook distillation prompt fires.
---

# Session retrospective

Distill what a future session would otherwise re-learn the hard way.

- **DECISIONS.md** (append-only): every non-obvious choice made this session and its rationale.
- **LESSONS.md** (append-only, negative knowledge): every dead end — what was tried, why it failed (root cause, specifically), what to do instead. Prioritize anything NOT visible in the code or spec.

The bar for a LESSONS entry: it must name the concrete mistake a future session would make without it. No named mistake, no entry — filler dilutes the real lessons and taxes every session-start injection.

Most sessions produce nothing worth keeping. If this one did, declare "no entries" explicitly. Declaring empty is the normal outcome; do not invent content to satisfy the ritual.
