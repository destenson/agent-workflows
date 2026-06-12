#!/usr/bin/env bash
# Contract: refuse reconnection attempts for a count or duration, then accept.
# Exercises: retry backoff and give-up policy.
# Usage:   faults/rtsp-reject.sh <n|secs>     e.g. "5" attempts or "30s"
# Exit:    0 once armed; non-zero on bad args / server not running.
set -euo pipefail
echo "TODO: implement rtsp-reject.sh <n|secs> on the fault server" >&2
exit 2
