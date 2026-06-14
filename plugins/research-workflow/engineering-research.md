Trimming to the applied ML/engineering world — no grants, no IRB, no journal track. The tree gets a lot shorter and the proposal becomes a decision gate rather than a funding artifact.

**Before the gate**
- One-pager / idea brief
- Problem statement + prior-art or existing-solution scan (light: what's already tried, internally and externally)

**The gate (the proposal)**
- The proposal itself — research, product, project, or feature flavor

**After greenlight — spec & design**
- PRP / PRD (the committed spec)
- Design doc + ADRs
- Experiment plan, for ML work specifically: hypotheses, metrics, datasets, baselines, ablations, stopping rules

**Execution**
- Run logs / experiment tracking
- Datasets with data and model cards
- Code, configs, environment

**Synthesis & decision**
- Eval / results report
- Decision memo: ship / iterate / kill

**Downstream**
- Retro or post-mortem
- Follow-on or revised proposal (the recursive edge)

The four proposal types are siblings at the same node — same skeleton, different audience and scope:

- **Research proposal** — "is this hypothesis worth testing?" Answers in knowledge; success is a learning, ship/kill is optional. Heavy on hypotheses and what would falsify them.
- **Feature proposal** — "should we add this to a thing that exists?" Scoped against a current product; lives or dies on user/maintenance cost vs. value.
- **Product proposal** — "should we build a new thing?" Wider; needs market/user framing and a bet on demand.
- **Project proposal** — "should we resource this effort?" The most about cost, timeline, and people; can wrap any of the above.

All four share: problem, proposed approach, why-now, cost/risk, success criteria, alternatives-considered. The differences are mostly which of those sections carries the weight.
