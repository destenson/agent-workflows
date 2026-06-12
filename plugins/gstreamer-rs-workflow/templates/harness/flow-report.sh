#!/usr/bin/env bash
# Contract: pull the per-link flow counters from the running app and report, per probe
# point, the buffer/byte rate and seconds since the last buffer. This turns "it froze"
# into "buffers stopped at link X, 43s ago, while upstream flowed."
# Usage:   harness/flow-report.sh
# Output:  one line per probe point (link id, rate, bytes, seconds-since-last-buffer),
#          machine-readable (stable columns or NDJSON).
# Exit:    0 on success; non-zero if the app's counters couldn't be read.
set -euo pipefail
echo "TODO: implement flow-report.sh against this app's flow-counter endpoint" >&2
exit 2
