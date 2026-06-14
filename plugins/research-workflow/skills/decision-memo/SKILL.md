---
name: decision-memo
description: Draft a decision memo — ship, iterate, or kill. Use after a results memo is finalized. Closes the loop from proposal to outcome and, if the decision is iterate or kill, spawns the next node in the tree.
---

# Decision memo

A decision memo makes the call. It is the `decision_memo` node in the document tree — it has inbound `justifies` edges from the results memo (and any other evidence), and it `spawns` either a follow-on proposal (iterate), a downstream PRP/PRD (ship), or closes the branch (kill).

The decision memo does not re-argue the results. It takes the results memo as given and states: given this evidence, here is the decision, here is why, and here is what happens next.

## How to run it

1. Ask the user: where is the results memo? The verdict — confirmed, falsified, or inconclusive — must be read before drafting the decision. A decision memo written without consulting the results memo is not a decision; it is an opinion.

2. Ask: who is making this decision and who needs to be aligned on it? Name the decision-maker explicitly. If multiple stakeholders need to agree, they should be listed — not to require consensus, but to make clear who was in the room.

3. Ask: what are the options? There are three:
   - **Ship** — the work is ready to move downstream (to a PRP, PRD, or production). What are the conditions?
   - **Iterate** — the results were inconclusive or partially confirmed, and a follow-on experiment is warranted. What specifically would be changed, and what hypothesis would the next round test?
   - **Kill** — the hypothesis was falsified or the cost/risk profile has changed enough that continuing is not justified. What does this imply for related work?

4. Ask: is there anything the results memo does not cover that is relevant to the decision? Cost changes, new information, competitive moves, team availability. Evidence beyond the experiment is allowed — but it must be named explicitly, not folded in silently.

5. Draft the memo. The decision must be stated in the first paragraph — not discovered at the end.

6. If the decision is **iterate** or **kill**, ask: should a follow-on proposal be created? If yes, note the spawn relationship — this is where the R&D loop recurses.

## Template

See [decision-memo-template.md](./decision-memo-template.md).
