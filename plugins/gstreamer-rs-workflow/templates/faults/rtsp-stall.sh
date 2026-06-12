#!/usr/bin/env bash
# Contract: accept a request at a chosen stage and never respond.
# Exercises: client-side request timeouts (often missing or unbounded).
# Usage:   faults/rtsp-stall.sh <stage>     stage = describe | setup | play
# Exit:    0 once armed; non-zero on bad args / server not running.
set -euo pipefail
echo "TODO: implement rtsp-stall.sh <stage> on the fault server" >&2
exit 2
