#!/usr/bin/env bash
# faults/partition.sh <duration_s> <peer> — block traffic to/from a specific peer
# for a window, then restore. Runs on-device (needs iptables). Restores the rules
# it added on exit even if interrupted.
set -euo pipefail

DURATION_S="${1:?usage: partition.sh <duration_s> <peer-ip>}"
PEER="${2:?usage: partition.sh <duration_s> <peer-ip>}"

cleanup() {
  iptables -D INPUT  -s "$PEER" -j DROP 2>/dev/null || true
  iptables -D OUTPUT -d "$PEER" -j DROP 2>/dev/null || true
}
trap cleanup EXIT

iptables -I INPUT  -s "$PEER" -j DROP
iptables -I OUTPUT -d "$PEER" -j DROP
sleep "$DURATION_S"
# cleanup() runs on EXIT
