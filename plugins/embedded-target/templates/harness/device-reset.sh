#!/usr/bin/env bash
# harness/device-reset.sh — restore the device to a known state. Run before every
# repro. Agent-driven runs on a stateful device drift (leftover processes,
# half-deployed binaries, degraded network from a prior fault sweep); without an
# idempotent reset, the agent chases residue from its own previous attempts.
source "$(dirname "$0")/env.sh"

# TODO(project): make this idempotent and complete. Typically:
#   - restart the application unit(s)
#   - clear scratch dirs that are safe to clear (list them in DEVICE.md)
#   - tear down any leftover netem/iptables fault state
#   - confirm the expected services are up before returning
# Example:
#   device_exec "$DEPLOY_TIMEOUT" '
#     sudo systemctl restart myapp
#     rm -rf /var/tmp/myapp-scratch/*
#     sudo tc qdisc del dev eth0 root 2>/dev/null || true
#     systemctl is-active --quiet myapp
#   '
echo "harness/device-reset.sh: not yet implemented for this project" >&2
exit 64
