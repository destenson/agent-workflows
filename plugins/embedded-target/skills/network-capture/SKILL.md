---
name: network-capture
description: Capture and analyze traffic on a video-heavy embedded link — headers-only ring buffer always on, control-plane in full, batch tshark analysis the agent reads as conclusions. Use when diagnosing protocol, loss, reordering, jitter, or timing bugs on the device's network.
---

# Network capture (video-heavy links)

Full pcap of a video stream is infeasible and unnecessary — protocol and timing bugs live in headers, sequence numbers, and timestamps; the payload is enormous by comparison and rarely needed.

- **Headers-only ring buffer, always on:** `tcpdump -s 128 -C <MB> -W <n> -w /var/log/pcap/ring`. Snaplen ~96–128 bytes keeps Ethernet/IP/UDP/RTP headers and drops payload, cutting volume ~50–100×. RTP sequence numbers and timestamps survive — enough to detect loss, reordering, gaps, and jitter.
- **Stratify by plane:** control-plane (signaling, ONVIF/RTSP, management) captured in full — low-volume, where protocol-usage bugs live; data-plane headers-only.
- **Capture payload only as a deliberate exception** (content-corruption bugs), never as a default.
- **Agent-readable analysis:** batch `tshark`, not interactive Wireshark. Small scripts in `harness/analyze/` (sequence-gap finder, inter-packet-time histogram, malformed-packet filter) so the agent reads conclusions, not packets. Wireshark stays the human tool for novel protocol forensics.
- On bug occurrence, `collect-diag.sh` snapshots the relevant ring window into the bundle.

Templates: `templates/harness/analyze/`.
