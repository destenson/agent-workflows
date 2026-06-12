# PIPELINE.md — {app name}

Standing context for the media pipeline, alongside DEVICE.md. Fill the healthy-state numbers from measured baselines and a committed healthy dot dump — not from guesses; a wrong baseline makes every later diff lie.

## Topology
- Canonical pipeline description (gst-launch-style text) and/or a committed healthy dot dump
- Dynamic behavior: which pads appear when; what signals wire what

## Elements
- Per element: ours / NVIDIA / stock GStreamer; version source; known quirks
- For forked elements: what the fork adds, upstream status of each piece

## Healthy-state numbers
- Expected buffer rates and caps at each probed link
- Steady-state counts: pads, threads, fds (the baselines leak checks compare against)
- Reconnect contract: max time from server return to flowing data; post-cycle baselines

## Probe points & controls
- Where the flow probes sit; control endpoint commands (log levels, dot dump, counter pull)

## Known traps
- Error-cascade pairs seen so far (element that posted vs. element that caused)
- Timing sensitivities (what vanished under which substitution, and what that implied)
- Pool-starvation signatures and pointers to the relevant LESSONS.md entries
