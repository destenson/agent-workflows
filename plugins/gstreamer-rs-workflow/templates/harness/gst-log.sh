#!/usr/bin/env bash
# Contract: change GST_DEBUG category levels in the running app WITHOUT a restart, so
# verbosity can be raised mid-incident without destroying the state being debugged.
# Usage:   harness/gst-log.sh <spec>      e.g. "rtspsrc2:7,rtpjitterbuffer:6,default:3"
# Output:  confirmation of the applied spec.
# Exit:    0 on success; non-zero if the app rejected or didn't apply the spec.
# Notes:   relies on the app exposing runtime GST_DEBUG control (control endpoint or
#          a signal handler). Pairs with the ring-buffer logger for dumping the window.
set -euo pipefail
echo "TODO: implement gst-log.sh against this app's runtime log-level control" >&2
exit 2
