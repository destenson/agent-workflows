#!/usr/bin/env bash
# repros/issue-N.sh — one repro per bug. Runs on-device, asserts, exits 0 (pass)
# or 1 (fail). Copy this to repros/issue-<number>.sh and fill it in.
#
# The reproduce-first gate: this must fail reliably under harness/loop.sh BEFORE
# any fix edits. For an environment-dependent bug, the repro INCLUDES its own
# environment — it invokes the relevant faults/ injection or a trace replay so the
# condition is created here, making the repro self-contained and deterministic.
set -euo pipefail

# --- arrange -------------------------------------------------------------------
# TODO(project): start/confirm the unit under test; set up any fixtures.
# For an environment-dependent bug, synthesize the trigger, e.g.:
#   TARGET_IF=eth0 faults/dropout.sh 200 &

# --- act -----------------------------------------------------------------------
# TODO(project): exercise the path that exhibits the bug.

# --- assert --------------------------------------------------------------------
# TODO(project): check the observable symptom. Exit 1 on the bug, 0 when fixed.
echo "issue-template: not yet implemented" >&2
exit 1
