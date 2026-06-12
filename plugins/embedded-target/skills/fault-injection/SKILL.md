---
name: fault-injection
description: Synthesize environment trigger conditions (dropouts, lossy/jittery links, partitions) as commands, and sweep the dropout-duration × protocol-phase space to make a timing-dependent bug deterministic. Use when a bug "depends on timing" or on network degradation and is hard to reproduce by hand.
---

# Fault injection

Network degradation is synthesizable; a library of small scripts gives the agent environmental conditions as commands (templates in `templates/faults/`, run on-device, needing `tc`/iproute2):

- `faults/dropout.sh <duration_ms>` — momentary total loss (netem `loss 100%`, or `ip link` down/up, or iptables drop).
- `faults/lossy.sh <pct> <jitter_ms>` — sustained radio-like impairment (netem loss/delay/reorder).
- `faults/partition.sh <duration_s> <peer>` — block a specific peer.
- `faults/sweep-dropout.sh` — parameter sweep: dropout duration × timing offset relative to a protocol-cycle anchor; runs the repro at each point; reports the reproducing region.

## The sweep is the key tool
"Hard to replicate, seems to depend on timing" often means the bug triggers only in a small region of (dropout length × phase within the protocol cycle). Searching that space by hand is impractical; an agent running `sweep-dropout.sh` overnight can cover it. Once the reproducing region is found, the repro script pins those parameters and the bug is deterministic from then on.

Trace replay complements injection where the trigger is a specific input sequence rather than degradation: harvested header traces or control-plane captures replayed via `tcpreplay` or a protocol-level player. Timing-sensitive interactions may not replay faithfully; injection sweeps are the fallback.

All fault scripts must restore clean state on exit (including on interrupt) so a sweep can't leave the device degraded.
