---
name: fit-review
description: Review a working change for approach-fit — was the bug fixed, or the feature built, the right way *for this codebase*? Catches reinvention of existing code, silently broken contracts, symptom-not-cause fixes, unbidden abstraction, and incoherence with local patterns. For bugfixes, verifies the bug is guarded by a test that fails without the fix (writing one if it is missing). Fixes what is trivial to fix, proposes the rest. Use after a change works and tests pass, distinct from diff-level bug review. Triggers: "did I fix this right", "fit review", "senior review", "is this the right approach".
---

# Fit review

A diff-level review asks *is this line correct*. This asks the question a senior engineer or team lead asks once the change already works: **was this the right way to solve it for this codebase?** Run it *after* the change is working and tests pass — its job is approach-fit, not correctness.

This is deliberately narrow. Defer, do not duplicate:
- correctness bugs → `code-review`
- reuse / efficiency / style cleanup → `simplify`
- whole-codebase debt or deletion sweeps → `entropy-pass`
- review *before* code exists → `plan-eng-review`

## Ground the judgment in both the change and the codebase

The verdict is only as good as what you read. Before judging:
1. Read the change itself (the diff against the base branch).
2. Read the project's recorded intent: SPEC.md, DECISIONS.md, LESSONS.md, and CLAUDE.md conventions.
3. **Actively search the codebase** for prior art and for callers of any contract the change touched. Most reinvention and most broken-contract findings are invisible from the diff alone — they only appear when you go look for what already existed and who depended on it. If you could not find prior art, say so explicitly rather than assuming none exists.

## The lens

For the change in front of you, ask:

1. **Reinvention.** Does equivalent capability already exist in the codebase? Did this hand-roll something a helper, type, or module already does?
2. **Contract integrity.** Do existing callers and implicit invariants still hold? Did it silently narrow or widen a contract (signature, error behavior, nullability, ordering, side effects) that others rely on?
3. **Symptom vs. cause.** Does it fix the root cause, or paper over the symptom where it surfaced? A guard added at the call site when the defect is in the callee is a symptom fix.
4. **Unbidden abstraction.** New indirection, options, layers, or generality that nothing yet requires (YAGNI). The right abstraction is the one a second concrete case forced, not one imagined here.
5. **Coherence.** Is the codebase more or less consistent after this? Did it follow the local pattern for this kind of thing, or import a foreign idiom that now sits alone?
6. **Conflict with recorded intent.** Does it violate a DECISIONS.md decision, a LESSONS.md lesson, or a SPEC.md constraint? If so, this is a standing-rule pushback, not a suggestion — flag it.

## If the change is a bugfix: is the bug guarded?

A fix with no test that fails without it is one accidental revert away from coming back. So for a bugfix, check that **a test exists that fails against the unfixed code and passes against the fix** — either a pre-existing test that was failing and now passes, or one written as part of this change to exercise the bug.

If there is no such guard, the test is usually missing, not impossible — and writing it is generally a "fix it" case (see below), not something to write a paragraph about. Write it at the *natural* level for this bug: the lowest level that genuinely fails on the defect, not a reflexive unit test where an integration test is what actually exercises the triggering condition.

The teeth of this check is verification, not belief: **revert the fix, confirm the test fails for the right reason, restore the fix, confirm it passes.** A "regression test" that still passes against the unfixed code guards nothing — treat that as a finding in its own right. If the bug genuinely cannot be exercised by a test in this environment (needs hardware, a live service, a timing race you can't force), say so explicitly and propose how it *could* be guarded rather than leaving it silently uncovered.

## Act on each finding: fix the cheap ones, propose the rest

The threshold is effort, not severity: **if applying the fix costs no more than writing up how to fix it, just fix it.** Do not narrate a one-line rework — make the edit, then report it in one line.

- **Fix it** when the rework is small and mechanical and does not change behavior: replace a reimplementation with the existing call, narrow a contract back to what callers expect, delete a redundant wrapper, follow the local pattern instead of the foreign one. Commit each such fix atomically.
- **Propose it** when the rework is structural, changes behavior, or rests on a judgment call that is the author's to make: the wrong approach entirely, a fix that needs the root cause addressed in another module, a design choice with real trade-offs. Here a writeup is genuinely cheaper than a wrong edit — give severity, the evidence (`file:line`, and the prior art or caller it should have respected), and a concrete "how a senior would do this instead."

When unsure which side of the line a finding falls on, propose rather than edit — a wrong fix costs more than a paragraph.

End with one verdict: **ship as-is** / **fixed in place** (list the edits) / **rework recommended** (the proposals) / **wrong approach, reconsider** (when the change works but solved the wrong problem).
