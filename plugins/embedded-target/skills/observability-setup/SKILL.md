---
name: observability-setup
description: Instrument an embedded target before the bug, not per-bug — structured boundary events, counters, a journal siphon that survives fast rollover, episodic capture on rate/signature triggers, and runtime log-level control without restarts. Use when setting up observability or when an occurrence was wasted because logs didn't cover the failing region.
---

# Observability (instrument before the bug, not per-bug)

The failure mode to eliminate: a bug occurs, the logs don't cover the failing region, and the occurrence is wasted. Instrumentation added after the fact is always one occurrence behind.

- **Structured events at every boundary and state transition:** socket errors, timeouts, reconnect attempts, buffer high-water marks, sequence-gap detections, state-machine transitions — one consistent, greppable taxonomy. Instrument these once, systematically, not per-bug.
- **Counters over logs for timing pathologies:** periodically sampled queue depths, drop/gap/restart counts. A counter time series often localizes a timing bug faster than any log narrative.

## Journal siphon (don't fight journald retention)
Test devices may run journald volatile/tiny, rolling fast — and that config is not ours to change. A sidecar runs `journalctl -f -o json` with query-level filtering and persists what matters under its own cap. JSON is newline-delimited with structured fields, so downstream analysis parses structure, never regexes prose.
- **Errors tier:** warnings-and-above from our units, persisted essentially forever; tiny volume.
- **Follower-held debug window, not journald-held:** a key failure mode is the bug's own verbosity evicting its own cause. Keep the last 10–30 min of debug stream in the follower's RAM (a deque) so nothing journald rolls can evict what the follower already holds. Size to the worst observed causal lead time.
- **Cursor sweep backstop:** a timer using `journalctl --cursor-file` backfills gaplessly across follower crashes and reboots.

## Episodic capture (triggers)
Many bugs announce themselves by log rate: quiet baseline, eruption at failure, recovery.
- **Rate anomaly (generic):** a per-unit rate spike fires capture with no known signature — this is what catches novel bugs.
- **Signature match (specific):** known patterns as config in `signatures.d/`, never code — dropped in (even scp'd mid-hunt) without rebuilding.
- On trigger: persist the in-memory pre-burst window (the cause, at debug level), keep persisting through the storm, stop at rate-normalization plus margin, then `collect-diag.sh` and notify. One bundle = cause + eruption + recovery.

## Runtime log-level control (no restarts)
- **Rust:** `tracing-subscriber` reload layer over `EnvFilter`, per-module directives; trigger via SIGUSR1/2 (`systemctl kill -s SIGUSR1 myapp` over ssh) or a unix-socket control endpoint. Trace tier lives in an in-memory ring-buffer layer that dumps on the same triggers; spans carry causal IDs into error sites.
- **Python:** `logging.getLogger("myapp.net").setLevel(...)` from the same signal handler.
