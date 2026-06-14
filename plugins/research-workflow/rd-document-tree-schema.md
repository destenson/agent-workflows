# R&D Document Tree — Schema

The tree is a set of **nodes** (documents) joined by **edges** (typed, directed
relations). It forms a DAG, not a strict tree: a node can have several parents
(an eval report derives from both a dataset and an experiment plan) and several
children. It stays acyclic because the relations that impose an order — `supersedes`,
`spawns` — always point from newer to older / from cause to effect.

This describes the structure only. How it's stored is a separate decision.

## Node

A node stands in for one document; it carries the document's identity and
relationships, while the prose itself lives wherever the content lives.

| field      | meaning                                                       |
|------------|---------------------------------------------------------------|
| id         | stable identifier                                             |
| type       | kind of document (see vocab)                                  |
| subtype    | refinement, e.g. proposal flavor — or none                    |
| title      | human label                                                   |
| status     | draft · active · done · superseded · killed                   |
| created    | when first written                                            |
| updated    | last change                                                   |
| authors    | who wrote it                                                  |
| content    | pointer to where the actual text lives                        |
| tags       | free-form labels                                              |
| attributes | type-specific fields (an experiment plan holds metrics, baselines, stopping rule; an eval report holds the measured numbers) |

## Edge

A directed, typed link between two nodes.

| field    | meaning                          |
|----------|----------------------------------|
| relation | the kind of link (see vocab)     |
| from     | source node                      |
| to       | target node                      |
| note     | optional: why the link exists    |

## Node types

`proposal`, `prior_art_scan`, `prp`, `design_doc`, `adr`, `experiment_plan`,
`run_log`, `dataset`, `dataset_card`, `model_card`, `eval_report`,
`decision_memo`, `retro`.

## Edge relations

Read each as *from* `relation` *to*.

| relation      | meaning                              | example (from → to)                              |
|---------------|--------------------------------------|--------------------------------------------------|
| `spawns`      | produced as a child of               | proposal → prp · eval_report → follow-on proposal |
| `implements`  | realizes a committed spec            | prp → proposal · code → design_doc               |
| `tests`       | gathers evidence about a claim       | experiment_plan → proposal hypothesis            |
| `derives_from`| built on top of an input             | eval_report → dataset · model → dataset          |
| `justifies`   | evidence supporting a decision       | eval_report → decision_memo                      |
| `supersedes`  | newer version replaces older         | prp (v2) → prp (v1)                              |
| `cites`       | references without depending on      | proposal → prior_art_scan                        |

`spawns` is the recursive relation: a results node spawning a follow-on proposal
is what closes the R&D loop.

## Reading the tree

- **Children / descendants** — follow edges outward from a node.
- **Provenance / ancestors** — follow edges inward to a node.
- **By relation** — restrict to one relation to answer a specific question,
  e.g. inbound `justifies` edges on a decision answer "what evidence backed this?"
