#!/usr/bin/env bash
# repros/all.sh — run the whole repro library as a regression suite (on a cadence).
# Each repros/issue-*.sh runs on-device and exits 0/1; this aggregates them and
# fails if any fails.
set -uo pipefail

here="$(dirname "$0")"
fail=0

for r in "$here"/issue-*.sh; do
  [[ -e "$r" ]] || continue
  if "$r"; then
    echo "PASS $(basename "$r")"
  else
    echo "FAIL $(basename "$r")"
    fail=1
  fi
done

exit "$fail"
