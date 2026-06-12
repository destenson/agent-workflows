#!/usr/bin/env bash
# harness/deploy.sh — language-aware deploy. Exit nonzero on failure.
#   Python: rsync delta + `uv sync` on-device (no GPU wheels rebuilt; lockfile pinned).
#   Rust:   copy the .deb, dpkg -i, systemctl restart the unit.
# The Rust artifact installed here must be byte-identical to production — same
# paths, same unit, same permissions — so there is no dev-vs-prod gap to chase.
source "$(dirname "$0")/env.sh"

# TODO(project): implement the real deploy. Examples:
#   Python:
#     rsync -az --delete ./src/ "$DEVICE_SSH":/opt/myapp/src/
#     device_exec "$DEPLOY_TIMEOUT" 'cd /opt/myapp && uv sync --frozen'
#   Rust:
#     scp target/aarch64-unknown-linux-gnu/debian/myapp_*.deb "$DEVICE_SSH":/tmp/
#     device_exec "$DEPLOY_TIMEOUT" 'sudo dpkg -i /tmp/myapp_*.deb && sudo systemctl restart myapp'
echo "harness/deploy.sh: not yet implemented for this project" >&2
exit 64
