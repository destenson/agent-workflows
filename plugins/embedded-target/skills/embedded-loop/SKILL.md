---
name: embedded-loop
description: Drive the on-device debug loop against a remote embedded target — reproducible (native/injected/replayed) or instrument-and-wait (irreducible environment dependence). Use when debugging behavior that only appears on-device, where the limiting resource is occurrences of the triggering condition.
---

# Embedded debug loop

Execution is the success signal: a fix is done when a checked-in repro passes on-device, never when the diff looks right. For environment-dependent bugs the scarce resource is not execution time but **occurrences** of the triggering condition — extract maximum information per occurrence (capture-first) and synthesize the condition where possible (fault injection).

Pick the loop shape:

## Reproducible (native, injected, or replayed)
hypothesis → edit → `harness/loop.sh <repro>` → analyze → iterate.

Gates:
- **Reproduce-first on-target.** No fix edits until `repros/issue-N.sh` fails reliably under `harness/loop.sh`. A plausible patch with no failing on-device repro is a guess.
- **Self-contained repro.** For environment-dependent bugs the repro *includes its environment* — it invokes fault injection (`faults/`) or trace replay to create the condition.
- **Attempt budget.** 2–3 failed fix attempts → write down the ruled-out hypotheses (LESSONS.md) → fresh session with that brief decides patch-or-rewrite.
- **Confirm under the real condition.** "Passes after" means passes end-to-end, repeatedly, under the triggering condition — not once by hand.

## Instrument-and-wait (irreducible environment dependence)
hypothesis → add targeted instrumentation that will confirm or kill it → deploy → wait for a watcher-harvested occurrence (or physically trigger) → analyze the bundle → narrow.

Wall-clock per cycle is long (there may be one or two occurrences per day), so **every deployed instrumentation round must be hypothesis-driven, never shotgun logging.** The capture-first standing rule applies: the response to any occurrence — lab or field — is harvest, then investigate. No occurrence is ever spent un-mined.

## Before any repro run
`harness/device-reset.sh` restores known state. Agent-driven runs on a stateful device drift (leftover processes, half-deployed binaries); without reset-before-run you chase residue from your own previous attempts.
