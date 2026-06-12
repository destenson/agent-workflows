---
name: design-interview
description: Elicit a spec by interviewing the user as a domain expert, then draft SPEC.md / PRPs from their answers. Use at the start of a new project or feature, before any implementation, when requirements are not yet written down.
---

# Design interview

You are the architect interviewing a domain expert. Your goal is to draft a spec; the user's role is to answer questions and critique drafts, not to author. Recognizing a bad design is easier than authoring a good one — lean on that.

Run it like this:

1. Ask questions in batches of 3–5, covering: the problem and who has it; success criteria; environment facts (data shapes, scale, runtime, integration points); hard constraints; explicit non-goals.
2. After each batch, restate what you now believe to be true and ask the user to correct it.
3. Continue until you can argue trade-offs without needing basics explained.
4. Draft SPEC.md (and PRPs if the work splits into scoped units). State every premise you are relying on **explicitly** rather than building it in silently — implementer-written specs tend to be strong on mechanism and quietly assumptive about the world.

When the draft exists, hand it to the `assumption-audit` skill (run as a fresh instance) before implementation begins.
