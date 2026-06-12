---
name: gst-failure-triage
description: Classify a GStreamer/DeepStream pipeline failure by symptom and take the right first diagnostic move. Use as the entry point for any pipeline bug — frozen video, bus ERROR, not-negotiated, hung state change, leak after N reconnects, timing/QoS, teardown crash.
---

# GStreamer failure triage

The first diagnostic step is classification by symptom; applying the wrong class's procedure wastes the iteration. Match the symptom, take the first move, then run the normal loop at the cheapest reproducing tier (see `gst-reconnect-repro` and the triage ladder).

| Symptom | Likely class | First move |
|---|---|---|
| ERROR on the bus | Loud failure — poster may not be the cause | Read the error, then check flow counters *upstream* of the posting element before trusting it. The poster is where damage was noticed, not done. |
| Video frozen / no output, no error | Silent stall | Flow report: find the last link where buffers still arrive — that brackets the stuck element. Thread-dump it (deadlock?) and check RTP stats (network stopped delivering, or element stopped processing?). |
| Never starts; "not-negotiated" | Caps negotiation failure | Dot dump — it shows negotiated caps on every link and where negotiation stopped. |
| Stuck transitioning (never reaches PLAYING) | Hung state change | Query each element's state with a timeout; the dot dump annotates per-element state, exposing the one that never completed. |
| Works, then degrades/fails after N reconnects or hours | Resource leak | Compare pad/thread/fd/memory counts against the healthy baseline (PIPELINE.md); run the `leaks` tracer over a repeated-cycle repro. |
| Output present but late/jerky/wrong | Timing/QoS | QoS messages on the bus, `latency` tracer, timestamp inspection at probes. |
| Crash/hang during teardown or reconnect; objects survive teardown | Object lifetime / leaked task | Thread dump; compare thread+object counts vs baseline. Then `gst-lifetime-review`. |
| Process crash | Ordinary native crash | The embedded doc's `backtrace.sh`; nothing GStreamer-specific. |

When a problem fits no row, fall back to the general procedure:

1. **Collect before theorizing.** One bundle the moment the failure is observed: bus message log, dot dump of the failed pipeline, flow report, recent debug-log window (`collect-diag.sh` produces all four). Each cheaply rules out whole classes — don't form a hypothesis until they're in hand.
2. **Compare against healthy.** Diff the failed dot dump against the committed healthy-baseline dump; diff flow rates and resource counts against PIPELINE.md's recorded healthy values. The discrepancy list is short and usually contains the lead.
3. **Localize, then minimize.** Use flow counters to name the suspect link/element, then `gst-pipeline-reduction` to shrink the repro around it.
4. **Run the normal loop** at the cheapest reproducing tier, under the standard gates: failing repro before any fix, attempt budget, record dead ends.

Two framework facts that mislead triage: an ERROR's poster is often a victim of an upstream cause (walk back with flow counters), and a DeepStream stall can present at the *opposite* end from its cause (buffer-pool starvation blocks upstream — see DeepStream notes).
