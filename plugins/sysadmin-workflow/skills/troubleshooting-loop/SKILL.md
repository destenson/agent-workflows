---
name: troubleshooting-loop
description: Drive the diagnose-and-fix loop against a live remote system — observe, probe read-only, hypothesize, change, verify, record. Use when troubleshooting a fault on a host in the fleet (a service is down, a host is unreachable, performance degraded, something that worked stopped working) where changes touch production state and the wrong fix on the wrong host has real blast radius.
---

# Troubleshooting loop

The loop runs against live systems, so the discipline is the opposite of editing code: you cannot freely try things and undo them. A change lands on a running host with real users behind it. The loop front-loads read-only investigation and treats every state change as narrated, targeted, and recorded.

The success signal is the symptom gone and **confirmed gone under the real condition** — not a plausible-looking change. A fix you believe in but have not verified on the host is a hypothesis, not a resolution.

## The loop

**Observe** → **probe read-only** → **hypothesize** → **change** → **verify** → **record**, iterating until the symptom is confirmed resolved.

### Observe
Pin down the symptom precisely before touching anything: what is wrong, on which host (name it from FLEET.md), since when, and how it surfaced. Check INCIDENTS.md — has this happened before? Check CHANGELOG.md — what changed recently on this host? Most "mysterious" breakage is a recent change.

### Probe read-only
Establish actual current state with commands that only read: logs, service status, resource usage, config contents, network reachability. Do not change anything yet. The goal is to know what you are working with, not to assume it. Read-only-first is the rule the safety gate cannot enforce for you — it is on you here.

### Hypothesize
State a specific, falsifiable cause and the single change that would confirm or fix it. "Disk full on web01 because the log rotation unit is masked" — not "probably disk or logs." A vague hypothesis produces a shotgun change.

### Change
Before running any state-changing command, narrate it: one sentence — what it does, on which host, why. Confirm the target host explicitly; most fleet damage is the right command aimed at the wrong box. Make the smallest change that tests the hypothesis. Record it in CHANGELOG.md as you make it (host, what, why, how to revert), not afterward.

### Verify
Confirm the symptom is actually gone, on the host, under the condition that triggered it — repeatedly if it was intermittent. "The command returned 0" is not verification; "the service answers requests again and has stayed up" is.

### Record
Resolved: append the root cause and resolution to INCIDENTS.md. Not the trigger — the cause. If a procedure worth repeating came out of this, capture it with the runbook-capture skill.

## Gates

- **No change before read-only investigation.** A patch with no established current-state picture is a guess aimed at production.
- **Name the host on every change.** The blast radius of the right fix on the wrong host is the most common self-inflicted incident.
- **Attempt budget.** 2–3 changes that do not resolve it → stop, write the ruled-out hypotheses into INCIDENTS.md, and reconsider whether you have the right root cause (or the right host) before continuing. Thrashing changes on a live system compounds risk.
- **Confirm under the real condition.** "Fixed" means verified on the host, repeatedly, under the triggering condition — not once by hand in a quiet moment.
