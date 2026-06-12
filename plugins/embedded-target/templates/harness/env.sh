#!/usr/bin/env bash
# Shared harness configuration. Every other harness script sources this. Edit the
# values for your target; there are deliberately no defaults that could silently
# point at the wrong device.
set -euo pipefail

# ssh destination — prefer a host alias from ~/.ssh/config with ControlMaster set
# there, so every call reuses one connection.
: "${DEVICE_SSH:?set DEVICE_SSH to the ssh destination, e.g. jetson-01}"

# Host-side directory where collected artifacts land.
ARTIFACT_DIR="${ARTIFACT_DIR:-./artifacts}"
mkdir -p "$ARTIFACT_DIR"

# Hard timeouts (seconds) by command class. A device hang must fail the run, never
# stall the caller. Tune in DEVICE.md's "Constraints & safety" section.
BUILD_TIMEOUT="${BUILD_TIMEOUT:-1800}"
DEPLOY_TIMEOUT="${DEPLOY_TIMEOUT:-600}"
RUN_TIMEOUT="${RUN_TIMEOUT:-300}"

# Run a command on-device under a hard timeout. SIGKILL because a hung device
# will not honor a polite signal. Usage: device_exec <timeout_s> <remote command...>
device_exec() {
  local t="$1"; shift
  timeout --signal=KILL "$t" ssh "$DEVICE_SSH" "$@"
}
