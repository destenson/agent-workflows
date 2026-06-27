---
name: calibrate
description: Reason under uncertainty by tracking graded confidence and updating it on evidence. Use when diagnosing a bug, choosing between approaches, estimating risk, or deciding whether to gather more information before acting — anytime a belief is uncertain and tool calls can sharpen it. Trigger on "diagnose", "is it worth checking", "how confident", "should I act yet", "root cause", or any decision resting on an unverified belief.
---

# Calibrate

A reasoning discipline for acting under uncertainty. Not probability math — graded belief plus an explicit update step. The goal is to tie tool use to confidence: gather evidence exactly when your confidence is below what the action needs, and say out loud how each piece of evidence moved you.

This is for situations with a real belief at stake (which fix, which cause, which approach, how risky). Skip it for mechanical edits and factual lookups — there's no belief to update.

## The loop

1. **State the belief and its confidence before acting.** Use words, not numbers: `confident` / `likely` / `even odds` / `long shot` / `can't tell yet`. Name what the confidence is resting on ("likely the config — but I'm going off the error message, haven't read the file").
2. **Treat "can't tell yet" as a trigger, not an answer.** If confidence is below what the next action needs, that is the signal to call a tool — read the file, run the probe, grep the usage. Don't act on a guess and don't guess when a cheap tool would settle it.
3. **On every tool result, state the update.** Which way it moved you and why: "the stack trace points at the parser, not the config — moved me off config toward a tokenizer bug." An observation that *didn't* move you is worth saying too ("logs were inconclusive, still even odds").
4. **Re-decide.** Confident enough to act? Act. Still short? Name the single cheapest tool that closes the remaining gap and use it. Stop gathering once more evidence won't change the decision.

## Rules

- **No invented numbers.** Don't write `P(bug)=0.7`. A fabricated probability looks rigorous and isn't — it's a guess in a lab coat. Numeric odds are allowed *only* when a real base rate exists to anchor to (a measured failure rate, a known distribution). Otherwise use the confidence words.
- **Keep prior and evidence separate.** Distinguish "what I believed coming in" from "what this new fact established." Don't let a fresh observation silently rewrite the story so it looks like you knew all along — that hides where the reasoning actually turned.
- **Don't over-collect.** More evidence has a cost. Once you're confident enough for *this specific* action, stop. The threshold scales with the stakes: reading a log line needs little; deleting data needs a lot.
- **Surface what would change your mind.** When you commit to an action while still uncertain, say what observation would flip it. That makes the call auditable and tells you what to watch for if it goes wrong.

## Shape of a calibrated step

> Belief: likely a stale cache, not a code bug — resting only on the symptom timing, which is weak.
> Confidence too low to start editing. Cheapest check: read the cache TTL config.
> → TTL is 24h and the data changed an hour ago. That moves me *off* stale-cache toward a real logic bug. Now confident enough to start reading the handler.
