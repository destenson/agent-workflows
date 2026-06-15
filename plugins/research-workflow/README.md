
# Research Workflow Plugin

The self-contained base workflow for the applied engineering R&D lifecycle — from problem framing through proposal, experiment, and outcome. It pairs a durable-memory spine (parallel to `agentic-workflow`, but for research) with skills for each stage of the process.

## The spine

Research has no fixed durable-artifact set the way software development does — what is worth keeping varies with the work, but commonly an **abstract**, a **proposal**, **experiment notes**, and **results**. These live in a dedicated **`research/`** directory (configurable via `RESEARCH_DIR`), kept out of the repo root.

- `SessionStart` → loads every top-level `.md` in `research/` into context (non-recursive, so bulky per-experiment logs in subdirectories don't flood the session) and emits a probe that forces a framing summary before any experiment or analysis.
- `UserPromptSubmit` → re-injects the research standing rules every turn: report divergence between artifacts and data, pre-commit criteria before peeking at outcomes, journal decisions and negative results as they happen.
- `Stop` → the distillation gate: prompts once per session to record decisions and especially falsified hypotheses / dead ends before ending. Its marker lives in `${TMPDIR:-/tmp}/research-workflow/`, never in the project; a pre-init guard keeps it silent in a repo that hasn't run `/research-workflow:research-init`.

There is deliberately **no complexity/line-cap gate** here — that is a code-maintainability concern from the software workflow, and the research artifacts are append-only records whose length tracks thoroughness, not debt. A research project doing heavy engineering can install `agentic-workflow` alongside this for the code-side gates.

**Skill:** `/research-workflow:research-init` scaffolds `research/` with the common starter artifacts (`abstract.md`, `proposal.md`, `experiments.md`, `results.md`) — a starting set, not a required one; add or drop to fit the work. The `research/` directory is meant to be committed; it is the project's research memory.

## Skills

### Upstream — framing before the proposal

- [problem-statement](skills/problem-statement/SKILL.md) — sharpen a vague problem into a bounded, falsifiable description before writing a proposal
- [literature-scan](skills/literature-scan/SKILL.md) — survey prior art (internal and external), surface failure modes, identify the gap
- [gap-analysis](skills/gap-analysis/SKILL.md) — identify the specific absence in prior work and generate testable hypotheses to address it

### The proposal

- [generate-research-proposal](skills/generate-research-proposal/SKILL.md) — "is this hypothesis worth testing?"
- [generate-feature-proposal](skills/generate-feature-proposal/SKILL.md) — "should we add this to a thing that exists?"
- [generate-product-proposal](skills/generate-product-proposal/SKILL.md) — "should we build a new thing?"
- [generate-project-proposal](skills/generate-project-proposal/SKILL.md) — "should we resource this effort?"

### Execution

- [experiment-design](skills/experiment-design/SKILL.md) — commit hypothesis, metric, baselines, ablations, and stopping rule before running
- [preregistration](skills/preregistration/SKILL.md) — timestamp the analysis plan before data is seen, to prevent post-hoc rationalization

### Synthesis and decision

- [results-memo](skills/results-memo/SKILL.md) — synthesize run output into a verdict against pre-committed criteria
- [negative-results](skills/negative-results/SKILL.md) — document falsified hypotheses, failed approaches, and abandoned efforts
- [decision-memo](skills/decision-memo/SKILL.md) — ship / iterate / kill, with explicit evidence and spawn edges to what comes next

## Reference

- [R&D Document Tree Schema](rd-document-tree-schema.md) — node types, edge relations, and DAG structure
- [Research Process](research-process.md) — full enumeration of documents produced during R&D, organized by lifecycle stage
- [Engineering Research](engineering-research.md) — the applied ML/engineering subset of the tree, trimmed of grant and IRB artifacts
