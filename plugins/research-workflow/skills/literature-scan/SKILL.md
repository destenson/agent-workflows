---
name: literature-scan
description: Conduct a literature review and prior-art scan — survey what has already been tried, internally and externally, before committing to a hypothesis or proposal. Use upstream of a research or product proposal. Produces a prior_art_scan node in the document tree.
---

# Literature scan

A literature scan answers: what has already been tried, what has been learned, and what remains open? Its purpose is to prevent re-inventing work that already exists and to surface the failure modes that prior attempts ran into. A proposal that cites no prior art is either in a genuinely new area (rare) or has not looked (common).

This is the `prior_art_scan` node in the document tree. A proposal `cites` it.

## How to run it

1. Ask the user: what is the problem or hypothesis this scan is for? Pull the problem statement if one exists. The scan is scoped to a specific question — a broad "survey the field" with no anchoring question produces a document that is interesting but not actionable.

2. Ask: what is already known internally? Previous experiments, failed projects, institutional knowledge that is not written down. Internal prior art is consistently underweighted. If the user says "nothing," probe: has anyone tried something adjacent? Has this been discussed and dropped?

3. Search externally. For each significant approach found:
   - What was tried?
   - What was the result?
   - Under what conditions does it work or fail?
   - Is the result reproducible (is there code, data, or a paper)?

4. Ask: what approaches were tried and failed? Negative results in prior art are as important as positive ones — knowing what didn't work, and why, changes the hypothesis.

5. Synthesize: after reviewing the landscape, identify the gap — what the prior work does not address, or addresses poorly, that the current problem requires. The gap is what justifies a new proposal.

6. Draft the scan. The most important output is not the list of prior work — it is the gap statement at the end.

## Structure

1. **Scope** — the specific question this scan was anchored to
2. **Internal prior art** — what has been tried inside the organization
3. **External prior art** — significant approaches, results, and conditions
4. **Failure modes in prior work** — what has been tried and failed, and why
5. **Gap** — what remains open that the current problem requires; this is what the proposal will address
6. **Sources** — citations for all external claims

## Template

See [literature-scan-template.md](./literature-scan-template.md).
