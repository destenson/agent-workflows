---
name: gap-analysis
description: Conduct a gap analysis and generate hypotheses — identify what the prior art does not cover and formulate testable hypotheses about how to address it. Use after a literature scan, before writing a research proposal.
---

# Gap analysis and hypothesis generation

A gap analysis identifies the specific absence in current knowledge or capability that a proposal will address. Hypothesis generation takes that gap and produces one or more testable claims about how to close it. Together these are the bridge between a literature scan and a research proposal.

A gap is not "nobody has done X." A gap is "prior approaches fail under condition Y because of mechanism Z, and we have reason to believe an alternative approach might not." Without a specific mechanism, the gap is an observation, not an argument.

## How to run it

1. Ask the user: is there a literature scan to work from? If yes, pull the gap section from it. If no, ask them to describe the state of prior art and what it fails to address — but flag that a more thorough scan should be done before committing to a proposal.

2. Ask: what is the failure mode of existing approaches for this specific problem? Be precise: does the prior work fail because it doesn't scale, because it requires data that isn't available, because it optimizes the wrong metric, or because it makes an assumption that doesn't hold in this context?

3. Ask: why do you believe there is a better approach? What evidence, observation, or theoretical argument suggests the failure mode can be addressed? If the user cannot articulate a reason to believe a better approach exists, the gap is identified but no hypothesis is ready yet.

4. Generate candidate hypotheses. A hypothesis must be:
   - **Specific** — names the approach and the claim being made about it
   - **Falsifiable** — states what observation would show it is wrong
   - **Bounded** — addresses the gap identified, not adjacent questions

5. For each candidate hypothesis, ask: what would you need to observe to believe this is wrong? If the answer is "nothing could convince me," it is not a hypothesis.

6. Help the user select the strongest candidate: which hypothesis, if confirmed, most directly closes the gap? Which is most tractable to test? These two questions often point at different hypotheses — name the tension explicitly.

## Output

The gap analysis produces:
- A precise statement of the gap (what prior work fails to address and why)
- One or more candidate hypotheses with falsification criteria
- A recommendation for which hypothesis to pursue first, with reasoning

This output is the direct input to the `generate-research-proposal` skill.
