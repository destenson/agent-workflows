#!/usr/bin/env bash
# Contract: ask the running app to write Graphviz .dot files of its live pipeline(s)
# — via its control endpoint or a signal — then pull them back locally.
# Usage:   harness/graph-dump.sh [tag]
# Output:  one or more .dot files in the diag artifact dir, named with [tag] and a timestamp.
# Exit:    0 on success; non-zero if the app didn't produce a dump.
# Notes:   .dot files are plain text; an agent greps them directly. Requires
#          GST_DEBUG_DUMP_DOT_DIR set in the app's service environment.
set -euo pipefail
echo "TODO: implement graph-dump.sh against this app's control endpoint" >&2
exit 2
