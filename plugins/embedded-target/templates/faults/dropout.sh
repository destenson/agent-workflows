#!/usr/bin/env bash
# faults/dropout.sh <duration_ms> — momentary total loss on the data interface,
# then clean restore. Runs on-device (needs tc/iproute2). Restores state on exit
# even if interrupted, so a sweep can never leave the link degraded.
set -euo pipefail

DURATION_MS="${1:?usage: dropout.sh <duration_ms>}"
: "${TARGET_IF:?set TARGET_IF to the data-plane interface, e.g. eth0}"

cleanup() { tc qdisc del dev "$TARGET_IF" root 2>/dev/null || true; }
trap cleanup EXIT

tc qdisc add dev "$TARGET_IF" root netem loss 100%
sleep "$(awk "BEGIN{print $DURATION_MS/1000}")"
# cleanup() runs on EXIT
