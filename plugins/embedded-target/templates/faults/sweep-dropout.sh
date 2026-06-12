#!/usr/bin/env bash
# faults/sweep-dropout.sh — search the (dropout-duration x phase) space for the
# region where a timing-dependent bug reproduces. "Hard to replicate, depends on
# timing" usually means the bug triggers only in a small region of dropout length
# crossed with phase within the protocol cycle. Searching that by hand is
# impractical; this covers it unattended and reports the reproducing region. Once
# found, pin the parameters in a repro and the bug becomes deterministic.
#
# Runs on-device. For each (duration, phase) point: wait to the phase offset
# relative to the protocol-cycle anchor, inject a dropout of that duration, then
# run the repro and record pass/fail.
set -euo pipefail

: "${TARGET_IF:?set TARGET_IF to the data-plane interface, e.g. eth0}"
REPRO="${REPRO:?set REPRO to the on-device repro script path}"

# Sweep ranges. Tune to the suspected protocol cycle; keep the grid coarse first,
# then refine around any hit.
DURATIONS_MS=(${DROPOUT_DURATIONS_MS:-50 100 200 400 800})
PHASES_MS=(${PHASE_OFFSETS_MS:-0 100 200 300 400})

here="$(dirname "$0")"

# TODO(project): replace with a real wait-to-anchor. The phase offset is measured
# from a protocol-cycle anchor (keyframe boundary, heartbeat, RTCP report, ...);
# without anchoring, "phase" is meaningless. This stub sleeps the raw offset.
wait_for_phase() { sleep "$(awk "BEGIN{print $1/1000}")"; }

echo "duration_ms phase_ms result"
for dur in "${DURATIONS_MS[@]}"; do
  for phase in "${PHASES_MS[@]}"; do
    wait_for_phase "$phase"
    "$here/dropout.sh" "$dur" &
    inject=$!
    if "$REPRO"; then result=pass; else result=FAIL; fi
    wait "$inject" 2>/dev/null || true
    echo "$dur $phase $result"
  done
done
