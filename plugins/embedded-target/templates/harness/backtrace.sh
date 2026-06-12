#!/usr/bin/env bash
# harness/backtrace.sh [core|pid] — non-interactive crash analysis. Cores must be
# enabled on-device so a crash yields text, not an interactive gdb session the
# agent can't drive. Prints a text backtrace to stdout.
source "$(dirname "$0")/env.sh"

TARGET="${1:?usage: backtrace.sh <core-file-path-on-device | pid>}"

# TODO(project): set the on-device binary path and adjust for core vs. live pid.
#   Core:      gdb -batch -ex bt -ex 'thread apply all bt' /opt/myapp/bin/myapp "$TARGET"
#   Live pid:  gdb -batch -ex bt -p "$TARGET"
device_exec "$RUN_TIMEOUT" "gdb -batch -ex bt -ex 'thread apply all bt' /opt/myapp/bin/myapp '$TARGET'"
