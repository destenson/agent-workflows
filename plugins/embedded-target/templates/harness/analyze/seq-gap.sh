#!/usr/bin/env bash
# harness/analyze/seq-gap.sh <ring.pcap> — report RTP sequence-number gaps from a
# headers-only capture, so the agent reads conclusions (where loss/reordering
# happened) rather than packets. Wireshark stays the human tool for novel
# forensics; routine analysis is scripted.
set -euo pipefail

PCAP="${1:?usage: seq-gap.sh <pcap>}"

# RTP_SSRC may be set to focus on one stream; empty means all.
filter="rtp"
[[ -n "${RTP_SSRC:-}" ]] && filter="rtp && rtp.ssrc == ${RTP_SSRC}"

tshark -r "$PCAP" -Y "$filter" \
  -T fields -e frame.time_epoch -e rtp.ssrc -e rtp.seq \
| awk '
  { ts=$1; ssrc=$2; seq=$3
    if (ssrc in last) {
      expected = (last[ssrc] + 1) % 65536
      if (seq != expected) printf "%s ssrc=%s gap: expected %d got %d (delta %d)\n", ts, ssrc, expected, seq, (seq-expected)
    }
    last[ssrc] = seq
  }'
