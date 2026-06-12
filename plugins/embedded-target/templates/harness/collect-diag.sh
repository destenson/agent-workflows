#!/usr/bin/env bash
# harness/collect-diag.sh — bundle the device's diagnostic state into one
# timestamped tarball on the host. The capture-first response to any occurrence:
# harvest, then investigate. No occurrence is ever spent un-mined.
source "$(dirname "$0")/env.sh"

stamp="$(date +%Y%m%d-%H%M%S)"
bundle="$ARTIFACT_DIR/diag-$stamp.tar.gz"
staging="diag-$stamp"

# TODO(project): adjust units, paths, and the pcap ring location for this target.
device_exec "$RUN_TIMEOUT" "
  set -e
  d=\$(mktemp -d)/$staging
  mkdir -p \"\$d\"
  journalctl -b -u myapp --no-pager      > \"\$d/journal.txt\" 2>&1 || true
  dmesg                                   > \"\$d/dmesg.txt\"   2>&1 || true
  cp /var/log/myapp/*.log                   \"\$d/\"           2>/dev/null || true
  cp \$(ls -t /var/log/pcap/ring* | head -1) \"\$d/\"          2>/dev/null || true
  uname -a; dpkg -l 'myapp*' 2>/dev/null    > \"\$d/version.txt\" || true
  tar -C \"\$(dirname \"\$d\")\" -czf - \"\$(basename \"\$d\")\"
" > "$bundle"

echo "diag bundle: $bundle" >&2
