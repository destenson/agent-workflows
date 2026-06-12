#!/usr/bin/env bash
# SessionStart hook: load DEVICE.md — the agent's operating map for the target —
# into context, the same way the base workflow loads its durable artifacts. The
# embedded loop is unusable without knowing the device's access, harness commands,
# safety constraints, and quirks; putting it in context at session open keeps the
# agent from guessing them.
#
# stdout from a SessionStart hook is added to the session context.
set -euo pipefail

if [[ -f DEVICE.md ]]; then
  printf '\n===== DEVICE.md =====\n'
  cat DEVICE.md
else
  printf '\nNo DEVICE.md found. This project targets a remote device but has no operating map — run /device-init before driving the on-device loop.\n'
fi
