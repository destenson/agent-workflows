---
name: define-release-target
disable-model-invocation: true
description: Set the release bar in HARDENING.md — what "pre-release" means for this specific product — and prioritize the gap ledger against it (must-fix-for-release vs. deferred). Use after assess-prototype, before working the ledger down. Extends SPEC.md rather than restating it when the agentic-workflow plugin is in use.
---

# Define the release target

Decide and record what "pre-release" means for *this* product, then use that bar to sort the gap ledger into what blocks release and what does not. This is the step that turns an inventory of imperfections into a plan: without a bar, every gap looks equally urgent and the prototype gets gold-plated instead of shipped.

Run this after `assess-prototype` has built the ledger. It writes the **Release bar** section of `HARDENING.md` and sets each ledger item's **Priority** — it does not add new gaps (that is assess) or fix them (that is convert).

## 1. Set the bar from the audience

The bar follows from who will touch this release. Ask the user if it is not already decided: internal beta, named design partners, a public release candidate? "Safe enough for me to demo" and "safe enough for a stranger to run unattended" are very different bars, and the difference decides how many ledger items are must-fix.

State the bar as concrete conditions that make it safe to put in front of that audience — derived from this product, not a generic list. "No silent data loss; every error a user can hit is diagnosable from the logs; runs from a clean checkout; no hardcoded secrets" is a bar. "Production-ready" is not.

Name what is **explicitly deferred** past pre-release too — scale, multi-tenancy, full accessibility, whatever is genuinely out of this release's scope. Writing the non-goals down is what licenses the convert phase to *not* do them.

## 2. Compose with SPEC.md, don't duplicate it

If this project runs the agentic-workflow plugin and a `SPEC.md` exists, its **Success criteria** and **Hard constraints** already say what the product must do and must never do. **Do not restate them in the release bar** — reference them, and record only the *productization* bar on top: the conditions a prototype can fail while still meeting SPEC's functional criteria (a script can produce correct output and still hardcode a password, crash on a malformed input, or only run on the author's laptop). Restating SPEC here manufactures exactly the cross-file divergence the standing rules exist to catch.

If there is no `SPEC.md`, define the bar inline in `HARDENING.md`. If, while setting the bar, you find it contradicts SPEC, stop and surface that — fix the SPEC or the bar, don't encode the contradiction.

## 3. Prioritize the ledger against the bar

Walk every ledger item and set its **Priority**:

- **must-fix-for-release** — leaving this open would breach the bar for the stated audience.
- **deferred** — a real gap, but it falls under the explicitly-deferred scope or doesn't threaten the bar for this audience.

The bar is the only criterion. A gap is not must-fix because it is easy or annoying; it is must-fix because shipping with it open breaks a release condition. If prioritizing reveals a gap nobody had a bar for, that is a signal the bar is incomplete — refine the bar, don't quietly upgrade the item.

## 4. Hand off

Report the bar, the must-fix list (this is the release-blocking work), and what was deferred and why. Point the user at **convert-prototype** to work the must-fix items down one at a time.
