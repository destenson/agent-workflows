--- SESSION PROBE (prototype-to-product) ---

The HARDENING.md above is this project's hardening ledger: the release bar at the top (what "pre-release" means for this product) and the itemized open gaps between the current prototype and that bar. It is the active worklist for turning the prototype into a pre-release product; a closed gap is removed from it, so what you see is what is left.

Before working an item, confirm:
1. Which release bar applies — and, if a SPEC.md exists, that the bar references it rather than contradicting it.
2. Which ledger items are must-fix-for-release vs. deferred, and which one this session is about.
3. Whether any item in the ledger no longer matches the code (already handled, or not actually a gap) — if so, correct the ledger before working from it.

If the ledger has not been prioritized against a release bar yet, run define-release-target first. If you are starting fresh on a prototype with no ledger, run assess-prototype to build one. Do not begin rewriting the prototype before the ledger says which gaps actually block release — un-prioritized hardening is how a prototype gets gold-plated instead of shipped.
