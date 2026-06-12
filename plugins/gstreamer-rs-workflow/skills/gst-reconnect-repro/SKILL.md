---
name: gst-reconnect-repro
description: Reproduce RTSP source/reconnection bugs with a scriptable RTSP fault server, assert-across-cycles invariants, and timing sweeps. Use for "works at first, fails after N reconnects/hours" bugs and any reconnection state-machine race.
---

# Reconnect reproduction

For source/reconnection bugs the triggering condition is server (mis)behavior, so the test environment is a server we control (gst-rtsp-server, from Rust or Python). Each fault exercises a specific client path normal operation never touches:

- `rtsp-kill <when>` — drop TCP mid-PLAY / after SETUP / mid-DESCRIBE → abrupt-disconnect detection at each protocol stage.
- `rtsp-stall <stage>` — accept a request, never respond → client request timeouts (often missing/unbounded).
- `rtsp-silent` — complete handshake, never send RTP → "connected but no data" detection.
- `rtsp-no-rtcp` — RTP normally, stop RTCP sender reports → keepalive/liveness logic keyed off RTCP.
- `rtsp-reject <n|secs>` — refuse reconnects for a count/duration, then accept → retry backoff and give-up policy.
- `rtsp-new-sdp` — accept reconnect, present different SDP (codec/caps) → whether reconnect handles a changed stream or silently feeds new data into a pipeline built for old caps.
- `rtsp-half-close` — close one TCP direction only → half-open handling (reads hang, writes "succeed").

**Assert across cycles, not within one.** Run N disconnect/reconnect cycles, check invariants after each: data flowing again within a deadline, and pad/thread/fd counts back to baseline. A reconnect that works once but leaks one pad per cycle is the classic rebuild bug — invisible to any single-cycle test. The per-cycle invariants are the same ones `gst-lifetime-review` enumerates.

**Timing sweeps find the race.** Reconnection-state-machine races typically manifest only when the fault lands in a narrow window relative to the protocol cycle. A scripted sweep over (fault type × timing offset) searches that space mechanically — overnight, by an agent — where a human cannot. Compose with the embedded doc's packet-level `tc netem` faults and its parameter-sweep technique. Once the reproducing region is found, the repro pins those parameters and the bug is deterministic.

**Tiers.** This bug class lives mostly at host tier (plugin in a real pipeline against a local fault server — iteration in seconds, no deploy). One caveat: the host's GStreamer version differs from the device's, so a host reproduction is strong evidence but a host *non*-reproduction doesn't clear the bug. Real servers (MediaMTX, actual cameras) are the validation tier: the fault server finds and pins the bug; the real camera confirms the fix holds.
