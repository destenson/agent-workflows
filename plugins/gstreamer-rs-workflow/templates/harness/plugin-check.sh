#!/usr/bin/env bash
# Contract: verify via gst-inspect-1.0 that OUR element resolves to the freshly built
# plugin — the git-stamped version string at the expected path — and not a shadowing
# distro copy or a stale registry-cache entry. HARD GATE: run after every deploy and
# before every repro. Debugging an old binary while believing it's new is the failure
# this prevents (causes: GST_PLUGIN_PATH ordering, a packaged copy shadowing ours,
# stale ~/.cache/gstreamer-1.0/).
# Usage:   harness/plugin-check.sh
# Exit:    0 if the resolved element matches the expected git-describe stamp and path;
#          non-zero otherwise (the repro must not proceed).
set -euo pipefail
echo "TODO: implement plugin-check.sh — assert gst-inspect-1.0 shows our git-stamped version/path" >&2
exit 2
