#!/usr/bin/env bash
# harness/build.sh — cross-compile for the target. Exit nonzero on failure.
#
# This is the deploy-tier build. For Rust, the inner loop (cargo check / cargo
# test) lives on the host and never reaches here; this builds the shippable
# artifact. For Python there is nothing to build — deploy syncs source and runs
# `uv sync` on-device.
source "$(dirname "$0")/env.sh"

# TODO(project): implement the real build. Examples:
#   Rust:   cross build --release --target aarch64-unknown-linux-gnu \
#             && cargo deb --no-build --target aarch64-unknown-linux-gnu
#   Python: exit 0   # nothing to build; deploy.sh handles `uv sync` on-device
echo "harness/build.sh: not yet implemented for this project" >&2
exit 64  # EX_USAGE — replace with the real build
