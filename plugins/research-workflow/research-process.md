An enumeration of documents produced during R&D, organized by where each document sits in the R&D lifecycle. A research proposal usually lands early, but the tree has nodes both upstream and downstream of it.

**Upstream (framing, before the proposal)**
- Idea capture / research memo / notebook stub
- Literature review / survey / state-of-the-art
- Annotated bibliography
- Problem statement or problem brief
- Position/vision white paper
- Concept note, pre-proposal, or letter of intent
- Feasibility study
- Gap analysis and landscape/competitive analysis
- Hypothesis register

**The proposal cluster**
- The research proposal itself
- Grant application / funding proposal
- Statement of work
- Project plan and milestone schedule
- Data management plan
- Ethics / IRB / safety review protocol
- Risk register
- Budget and resourcing plan
- Preregistration (for empirical work)
- Theory of change / logic model

**Design and specification**
- Experimental design / methods protocol
- Test plan
- Architecture and design docs
- ADRs (decision records)
- Interface/API or component specs
- Power analysis / sample-size justification

**Execution and record**
- Lab notebook and run logs
- Datasets with data dictionaries / codebooks
- Provenance and metadata records
- Code repos, configs, environment/lockfiles
- Progress reports and status updates
- Failure logs / negative-results record

**Analysis and synthesis**
- Analysis plan and analysis notebooks
- Results / findings memo
- Internal technical report
- Internal peer critique / review notes

**Output and dissemination**
- Preprint
- Manuscript (journal or conference paper)
- Poster, slide deck, talk
- Released dataset/code with README, datasheet, model card
- Reproducibility/replication package
- Supplementary materials and appendices

**Downstream (impact and continuation)**
- Invention disclosure / patent application
- Funder closeout / final report
- Tech-transfer and productization docs (PRD, spec)
- Standards proposal / RFC
- Retrospective / post-mortem
- Follow-on proposal (this is where the tree recurses)
- External citations and derivative works (other authors' nodes attaching to yours)

On the tree structure itself: the interesting part is the edges, not just the nodes. A single proposal fans out into multiple experiment protocols; each protocol fans into many run logs and datasets; those converge back into one results memo and then a paper. So it's not a clean chain — it's a DAG with branch points at design time and merge points at synthesis time. Edges carry semantics worth capturing: *supersedes* (v2 of a protocol), *derives-from* (analysis ← dataset), *justifies* (results → claim), *cites*, and *spawns* (results → follow-on proposal, the recursive edge). Negative-results and failure nodes are the ones most often dropped from the recorded tree even though they carry the most reuse value.

