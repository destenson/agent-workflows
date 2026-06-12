#!/usr/bin/env bash
# Contract: run a pipeline from a gst-launch-1.0 description (or a named minimal Python
# runner when dynamic pads/signals are needed) with a hard timeout, GST_DEBUG capture,
# and a dot dump on exit or stall. Per-run tracers (leaks, latency) enabled by flag/env.
# Usage:   harness/pipeline-run.sh <desc>        desc = gst-launch string or runner name
# Output:  exit code + captured GST_DEBUG log + dot dump in the diag artifact dir.
# Exit:    pipeline's result; non-zero on timeout/stall/error.
# Notes:   hard timeout is mandatory — a stall must fail the run, never hang the caller.
set -euo pipefail
echo "TODO: implement pipeline-run.sh with hard timeout, GST_DEBUG capture, dot-on-exit" >&2
exit 2
