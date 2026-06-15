---
name: assess-prototype
disable-model-invocation: true
description: Analyze a working prototype and build (or extend) the HARDENING.md gap ledger — the concrete list of what is prototype-grade and below a pre-release bar. Use when starting to harden a prototype into a product, or re-running as the prototype evolves to catch newly-introduced gaps.
---

# Assess the prototype

Produce an honest, concrete inventory of the gaps between this working prototype and a pre-release product, written into `HARDENING.md`. The output is a ledger of specific, locatable gaps — not a grade and not a generic best-practices checklist. A prototype proves an idea works; this assessment finds where it is not yet fit for someone other than its author to depend on.

This skill only *finds and records* gaps. It does not set the release bar (that is `define-release-target`) and does not fix anything (that is `convert-prototype`). Keep those boundaries — an assessment that starts fixing loses the inventory.

## 1. Orient before judging

Read enough of the prototype to assess it against reality, not against a template: entry points and the main flow, how it is configured and run, where it touches the outside world (network, disk, processes, other services), its dependencies, and what tests exist. If the project runs the agentic-workflow plugin, read `SPEC.md` for what it is *supposed* to do — a gap is only a gap relative to intended behavior.

## 2. Derive the gaps from this prototype

For each part of the system, ask what would break, mislead, or be unsafe the first time someone other than the author runs it in a setting that matters. The dimensions below are prompts to think along, **not a checklist to tick** — most prototypes will have gaps in only some, and a given prototype may have an important gap in none of them and a serious one nowhere on this list. Find the gaps that are actually present:

- **Failure handling** — what happens on the unhappy path? Errors swallowed, `unwrap`/bare-`except`, partial writes, no timeouts.
- **Config & secrets** — hardcoded paths, endpoints, or credentials; config read without validation so a typo fails silently or late.
- **Data integrity** — operations that can corrupt or silently drop data; no idempotency where retries will happen.
- **Observability** — when it misbehaves in front of a user, can you tell why? Logs, error surfaces, diagnosability.
- **Tests** — is the load-bearing behavior covered enough that hardening changes won't silently break it?
- **Packaging & install** — does it run from a clean checkout by someone who isn't the author, or only on the author's machine?
- **Dependency hygiene** — unpinned, abandoned, or known-vulnerable dependencies.
- **Docs** — can the target user start without asking the author?

Record what you genuinely find. A short ledger of real, specific gaps is worth more than a long one padded to cover every dimension. State uncertainty honestly — "Gap: suspected race on concurrent writes, not yet confirmed" is more useful than a confident guess.

## 3. Write the ledger — augment, never clobber

- If `HARDENING.md` does not exist, create it from `${CLAUDE_PLUGIN_ROOT}/templates/HARDENING.md` and fill the ledger. Leave the **Release bar** section as its placeholder — that is `define-release-target`'s job.
- If `HARDENING.md` already exists, **add to it in place.** This skill is meant to be re-run as the prototype grows; a re-run adds newly-found gaps and corrects entries that no longer match the code. It must never wipe the open ledger. A closed gap was removed when it was fixed, so it is no longer in the code as a gap — assess by reading the current code, and a re-run will not resurrect something already hardened. Do not touch the Release bar or anyone's priorities on a re-run.

When creating the file, replace `{project}` in the header with the real project name. Fill each entry from what you observed: **Where**, **Gap** (concrete, with the failure it causes), **Done when** (the observable condition that would close it). Leave **Priority** unset — prioritizing against the bar is the next skill's job, not something to guess here.

## 4. Hand off

Report the gaps you recorded grouped by how much they worry you, and what you could not assess (and why). Then point the user at **define-release-target** to set the pre-release bar and decide which of these gaps actually block release — without that, the ledger is a list of everything imperfect, which is not yet a plan.
