#!/usr/bin/env bash
# Contract: drop the TCP connection at a chosen protocol stage.
# Exercises: detection of an abrupt disconnect at each stage.
# Usage:   faults/rtsp-kill.sh <when>     when = play | setup | describe
# Exit:    0 once the fault has been injected; non-zero on bad args / server not running.
# Notes:   implemented against the scriptable gst-rtsp-server test server we control.
set -euo pipefail
echo "TODO: implement rtsp-kill.sh <play|setup|describe> on the fault server" >&2
exit 2
