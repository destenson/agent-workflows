#!/usr/bin/env bash
# harness/loop.sh <repro> — the single command an agent iterates with:
#   build → deploy → device-reset → run <repro> → collect-diag.
# The repro's exit code is preserved as this command's exit code. collect-diag
# runs regardless of pass/fail, so every iteration leaves a harvestable bundle.
source "$(dirname "$0")/env.sh"

REPRO="${1:?usage: loop.sh <repro-script>}"
here="$(dirname "$0")"

"$here/build.sh"
"$here/deploy.sh"
"$here/device-reset.sh"

"$here/run.sh" "$REPRO"
rc=$?

"$here/collect-diag.sh" || true

echo "loop result: repro exited $rc" >&2
exit "$rc"
