#!/usr/bin/env bash
# Copy template files into a project, never overwriting what already exists.
#
# Init/scaffold skills all need the same mechanical, safety-bearing step: copy
# each template into place only if the destination does not already exist, so a
# hand-edited artifact is never clobbered. Done by hand that invariant rests on
# the model remembering to check every file; here it is deterministic.
#
# Usage:
#   scaffold.sh <template_root> <dest_dir> <relpath>...
#
#   <template_root>  directory holding the templates (e.g. $CLAUDE_PLUGIN_ROOT/templates).
#   <dest_dir>       directory to copy into (the caller resolves any env-var default).
#   <relpath>...     paths under <template_root> to copy. A relpath may be a file
#                    or a directory; a directory is walked and each file inside is
#                    copied at the same relative path, preserving subdirectories.
#
# Copies preserve the template's mode (cp -p), so a template tracked executable
# (e.g. a harness script at 100755) lands executable and a doc template does not.
# The template's own mode is the source of truth; this script makes no decision
# about which files should be executable.
#
# For every file considered, prints one line the calling skill reports verbatim:
#   created <relpath>     the file did not exist and was copied
#   skipped <relpath>     the file already existed and was left untouched
# A file missing from <template_root> is a packaging error, reported as:
#   missing-template <relpath>
# and makes the script exit non-zero after processing the rest.
set -euo pipefail

if [[ $# -lt 3 ]]; then
  echo "usage: scaffold.sh <template_root> <dest_dir> <relpath>..." >&2
  exit 2
fi

template_root=$1
dest_dir=$2
shift 2

if [[ ! -d "$template_root" ]]; then
  echo "scaffold.sh: template root not found: $template_root" >&2
  exit 2
fi

had_missing=0

# Copy a single file at relpath if the destination is absent.
copy_one() {
  local rel=$1
  local src="$template_root/$rel"
  local dst="$dest_dir/$rel"
  if [[ ! -f "$src" ]]; then
    echo "missing-template $rel"
    had_missing=1
    return
  fi
  if [[ -e "$dst" ]]; then
    echo "skipped $rel"
    return
  fi
  mkdir -p "$(dirname "$dst")"
  cp -p "$src" "$dst"
  echo "created $rel"
}

for relpath in "$@"; do
  src="$template_root/$relpath"
  if [[ -d "$src" ]]; then
    # Walk the directory and copy each file at its path relative to template_root.
    while IFS= read -r -d '' file; do
      copy_one "${file#"$template_root"/}"
    done < <(find "$src" -type f -print0 | sort -z)
  else
    copy_one "$relpath"
  fi
done

exit $(( had_missing ? 1 : 0 ))
