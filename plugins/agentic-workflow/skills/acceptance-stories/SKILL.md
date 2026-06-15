---
name: acceptance-stories
description: Decompose a written SPEC into discrete user stories, each carrying acceptance criteria and concrete test scenarios, cross-linked back to the spec and the assumptions it depends on. Use after a spec exists and has been assumption-audited, before implementation, to turn "what the system should do" into verifiable units an implementer can check against.
---

# Acceptance stories

You are the product owner translating a spec into units of work that an implementer can build *and verify*. The output is not narrative for its own sake — a story earns its place only by carrying something checkable. If a story has no acceptance criteria and no test scenario, delete it; it is ceremony.

Input is `SPEC.md` (and any PRPs). If no spec exists yet, stop and point the user at `design-interview` first.

Work like this:

1. Read the spec and list the distinct user-facing behaviors it promises. One behavior per story. Resist splitting by implementation layer — split by what the user can observe.
2. For each story, write:
   - **Behavior** — what the user can do and what they observe, in plain language. The "As a / I want / so that" frame is optional; use it only when the *so that* clause carries real information about why the behavior exists.
   - **Acceptance criteria** — Given/When/Then assertions an implementer can check against. Each criterion must be objectively pass/fail. Vague criteria ("works well", "is fast") are not acceptance criteria; name the threshold or cut it.
   - **Test scenarios** — concrete cases that exercise the criteria, including the boundary and failure cases, not just the happy path. These are the verification targets the implementing agent will reach for, so they are the most valuable part of the story — write them as if someone will turn each one into an actual test.
3. Cross-link each story: cite the SPEC line(s) it realizes, and link the assumptions it leans on with `[[assumption-name]]`. A story that depends on an unvalidated, high-cost assumption is a flag — surface it rather than burying it in a criterion.
4. Flag gaps back to the spec. If decomposing exposes a behavior the spec never settled, or two stories that contradict, stop and report it (standing rule 1) — do not invent the answer in an acceptance criterion.

Scope boundary: this skill stops at *what must be true for the behavior to be correct*. It does not break work into implementation tasks — hand the stories to `spike` or `prp-generation` for that. Keep the two concerns separate; mixing them is how acceptance criteria quietly turn into a design spec.
