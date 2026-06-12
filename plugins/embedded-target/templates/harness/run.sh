#!/usr/bin/env bash
# harness/run.sh <script> — copy a repro/test script to the device, run it under a
# hard timeout, and pull back its exit code + stdout/stderr. The script's own exit
# code is this command's exit code, so an agent reads pass/fail directly.
source "$(dirname "$0")/env.sh"

SCRIPT="${1:?usage: run.sh <local-script-path>}"
[[ -f "$SCRIPT" ]] || { echo "no such script: $SCRIPT" >&2; exit 66; }  # EX_NOINPUT

remote="/tmp/$(basename "$SCRIPT")"
stamp="$(date +%Y%m%d-%H%M%S)"
out="$ARTIFACT_DIR/run-$stamp.out"
err="$ARTIFACT_DIR/run-$stamp.err"

scp -q "$SCRIPT" "$DEVICE_SSH":"$remote"
device_exec "$RUN_TIMEOUT" "chmod +x '$remote' && '$remote'" >"$out" 2>"$err"
rc=$?

echo "stdout: $out" >&2
echo "stderr: $err" >&2
exit "$rc"
