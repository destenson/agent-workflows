# Hardening ledger — {project}

_The gap between this working prototype and a pre-release product, made explicit and worked down item by item. Durable project state: commit it. Not an append-only history — an item stays until it is closed, then it is removed. The ledger answers "what still stands between this prototype and release," not "everything that was ever rough." The record of what was hardened lives in the commit history; this file tracks only what is left._

## Release bar

_What "pre-release" means for THIS product — the standard the prototype must reach, no higher. Set by define-release-target._

<!--
If this project runs the agentic-workflow plugin (a SPEC.md exists), DO NOT restate
its success criteria and hard constraints here — reference them, and record only the
productization-specific bar the prototype must additionally meet (a prototype can
satisfy SPEC's functional success criteria while still being unfit to put in front
of an outside user). If there is no SPEC.md, define the bar inline.
-->

- **Audience for this release:** {who touches it — internal beta, design partners, public RC? this sets how high the bar is}
- **Must hold for release:** {the conditions that make it safe to put in front of that audience — e.g. no silent data loss, errors are diagnosable, runs from a clean checkout, secrets are not hardcoded. Derive these from this product, not a generic checklist.}
- **Explicitly NOT in this release:** {hardening that is real but deferred past pre-release — scale, multi-tenancy, full a11y, etc. Naming these is what keeps the convert phase from gold-plating.}
- **References:** {link SPEC.md / DECISIONS.md sections this bar extends, if present}

## Ledger

_One entry per open gap. Newest or highest-priority first is fine — priority is the field that orders work, not position. Remove an entry when the gap is closed; the release bar decides which items block release at all._

### {short gap title}
- **Priority:** must-fix-for-release <!-- must-fix-for-release | deferred -->
- **Dimension:** {what kind of gap — e.g. error handling, config/secrets, observability, tests, packaging/install, docs, data integrity, dependency hygiene. A label, not a category to force every item into.}
- **Where:** {file / module / command / surface where the prototype falls short}
- **Gap:** {what is prototype-grade here and why it is below the bar — be concrete: "parses config with no validation; a typo'd key fails silently at runtime" beats "needs better config handling"}
- **Done when:** {the observable condition that closes this item — the acceptance test, not "improve X". This is what a commit will be checked against.}
- **Notes:** {risk if shipped as-is, suspected blast radius, anything that saves the next person time — optional}
