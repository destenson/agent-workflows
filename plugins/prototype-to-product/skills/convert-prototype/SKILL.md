---
name: convert-prototype
disable-model-invocation: true
description: Work the HARDENING.md ledger down incrementally — turn the prototype into a pre-release product one must-fix item at a time, each as a focused commit, removing items from the ledger as they close. Use after define-release-target has set the bar and prioritized the ledger.
---

# Convert the prototype

Drive the prototype across the release bar by closing `HARDENING.md`'s must-fix items one at a time. Each item becomes a focused change, verified against its **Done when** condition, committed on its own, and removed from the ledger once closed. The ledger and the commit history advance together so that at any point it is clear what still stands between the prototype and release.

Run this after `define-release-target` has set the bar and prioritized the ledger. If the ledger has no priorities yet, run that first — working an un-prioritized ledger is how a prototype gets gold-plated.

## The loop

Pick the next **must-fix-for-release**, open item — highest-risk first unless one is a prerequisite for another — and:

1. **Read the item, then the code.** Confirm the gap is still real and still matches the code. If it was already handled, or isn't actually a gap, correct or drop the ledger entry and move on — don't manufacture a change to justify the item.
2. **Make the smallest change that meets "Done when."** Hardening means handling the edge case the prototype ignored, not hiding it: surface the error, validate the input, externalize the secret. **Do not add a fallback or graceful-degradation path that masks a failure** unless the release bar explicitly calls for that degradation — a silent fallback during hardening reintroduces exactly the kind of hidden failure you are here to remove.
3. **Verify against the acceptance condition**, not against the diff looking right. If "Done when" was "malformed config fails loudly with the offending key," cause a malformed config and watch it fail loudly. If the item needed test coverage to be safe to change, that coverage is part of the item.
4. **Commit this item alone**, naming the ledger item it closes. One item per commit: the history maps to the ledger, and an item that fails review reverts without dragging others with it.
5. **Remove the item from `HARDENING.md`** in the same change — the ledger tracks only what is left, and the commit that closes the item is the record that it was done. If you discovered a new prototype-grade gap while working this one, add it to the ledger (don't silently fix it inline — that hides scope and breaks the one-item-per-commit mapping); prioritize it against the bar before deciding to work it.

Repeat until no must-fix items remain open.

## Knowing when to stop

The release bar — not an empty ledger — is the finish line. Deferred items can stay open at release; that is what "deferred" meant. When the last must-fix item closes, say so plainly and report what remains deferred, so the user decides whether the bar held or has shifted. Resist working deferred items just because they are there: past the bar is gold-plating, and the standing rules call that out for a reason.

If an item resists — two or three real attempts and the **Done when** condition still won't hold — stop and write down what you ruled out (in `DECISIONS.md`/`LESSONS.md` if the agentic-workflow plugin is in use, otherwise in the item's **Notes**) rather than forcing it. A must-fix item that can't be met may mean the bar was wrong, the gap is deeper than assessed, or the prototype's design fights the fix — all of which are the user's call, not something to paper over.
