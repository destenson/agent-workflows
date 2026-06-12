#!/usr/bin/env bash
# faults/lossy.sh <pct> <jitter_ms> [duration_s] — sustained radio-like impairment
# (loss + delay jitter + reordering) on the data interface. Without a duration it
# holds until interrupted; either way it restores clean state on exit.
set -euo pipefail

PCT="${1:?usage: lossy.sh <pct> <jitter_ms> [duration_s]}"
JITTER_MS="${2:?usage: lossy.sh <pct> <jitter_ms> [duration_s]}"
DURATION_S="${3:-}"
: "${TARGET_IF:?set TARGET_IF to the data-plane interface, e.g. eth0}"

# Base delay around which jitter varies; reorder correlation models bursty radio.
BASE_DELAY_MS="${BASE_DELAY_MS:-20}"
DELAY_CORRELATION="${DELAY_CORRELATION:-25%}"

cleanup() { tc qdisc del dev "$TARGET_IF" root 2>/dev/null || true; }
trap cleanup EXIT

tc qdisc add dev "$TARGET_IF" root netem \
  loss "${PCT}%" \
  delay "${BASE_DELAY_MS}ms" "${JITTER_MS}ms" "$DELAY_CORRELATION"

if [[ -n "$DURATION_S" ]]; then
  sleep "$DURATION_S"
else
  echo "lossy: impairment active on $TARGET_IF; Ctrl-C to restore" >&2
  sleep infinity
fi
