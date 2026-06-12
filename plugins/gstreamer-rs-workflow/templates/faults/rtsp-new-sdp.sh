#!/usr/bin/env bash
# Contract: accept the reconnect but present a different SDP (changed codec/caps).
# Exercises: whether reconnect handles a changed stream, or silently feeds new data
#            into a pipeline built for the old caps.
# Usage:   faults/rtsp-new-sdp.sh
# Exit:    0 once armed; non-zero if the server isn't running.
set -euo pipefail
echo "TODO: implement rtsp-new-sdp.sh on the fault server" >&2
exit 2
