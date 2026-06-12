---
name: spike
description: Build a throwaway implementation whose only purpose is to validate or falsify one high-risk assumption by making real contact with the data, library, or environment. Use for any high-cost unvalidated assumption before committing to the design.
---

# Spike

This is a throwaway spike. Its only purpose is to validate or falsify one assumption by making real contact with reality.

1. State the single assumption under test.
2. Build the **minimum** throwaway implementation that touches the real data / library / environment. Do not generalize, do not handle errors beyond what the test needs, do not produce reusable code.
3. End by stating: **validated** or **falsified**, the evidence, and any lessons.

The code is discarded. What is kept:
- The assumption's status in ASSUMPTIONS.md (`validated-as-of` records which spike, what data, when — validation is never terminal; it returns to scrutiny when those conditions change; `falsified` requires a SPEC correction before it is closed).
- Any dead end worth keeping, in LESSONS.md.
