---
name: assumption-audit
description: Extract every premise a spec takes for granted, rank by cost-if-false, and write ASSUMPTIONS.md. Run as a fresh instance with the spec as the only input, before implementation. Use after a spec or PRP is drafted.
---

# Assumption audit

Your entire task is assumption extraction. Do not review style, structure, or completeness — those are not the job, and a generic review mostly comes back as style feedback. A fresh instance with no investment in the draft critiques more honestly than the author would; that is why this runs separately.

Enumerate every claim the specification takes for granted: about the environment, the data, library/tool behavior, performance characteristics, user behavior, and the problem itself. Include premises **implied** by the design rather than stated.

For each assumption:
- State it in one sentence.
- Classify cost-if-false: low / medium / high.
- Propose the cheapest test that would validate or falsify it.

Output as the ASSUMPTIONS.md table (see the plugin's `templates/ASSUMPTIONS.md`).

**Gate:** implementation does not begin while any high-cost assumption is `unvalidated`. Each high-cost unvalidated assumption should get a `spike` next.
