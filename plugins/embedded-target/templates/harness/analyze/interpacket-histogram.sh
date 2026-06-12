#!/usr/bin/env bash
# harness/analyze/interpacket-histogram.sh <ring.pcap> — histogram of inter-packet
# arrival times (ms) for the data plane, to surface jitter/stall pathologies as a
# distribution rather than a packet dump.
set -euo pipefail

PCAP="${1:?usage: interpacket-histogram.sh <pcap>}"
BUCKET_MS="${BUCKET_MS:-5}"   # histogram bucket width in milliseconds

tshark -r "$PCAP" -T fields -e frame.time_epoch \
| awk -v bucket="$BUCKET_MS" '
  NR>1 { dt_ms = ($1 - prev) * 1000; b = int(dt_ms / bucket) * bucket; count[b]++ }
  { prev = $1 }
  END { for (b in count) printf "%6d-%-6d ms : %d\n", b, b+bucket, count[b] }' \
| sort -n
