#!/usr/bin/env bash
# SessionStart hook: load the durable research artifacts into context and emit the
# session probe. One-shot context loading at session open; the standing rules keep
# the discipline live per-turn.
#
# Research has no fixed artifact set the way the base agentic workflow does (SPEC/
# ASSUMPTIONS/DECISIONS/LESSONS) — the durable docs vary with the work, commonly
# an abstract, a proposal, experiment notes, and results. So rather than name a
# fixed list, this loads every top-level .md in the research directory. It is
# deliberately NON-recursive: framing and summary docs live at the top level and
# belong in context; bulky per-experiment run logs live in subdirectories and are
# left out so they do not flood the session.
#
# The directory keeps these out of the repo root (default research/, overridable)
# and is announced so the slash commands, which cannot read this env var, write to
# the same place.
#
# stdout from a SessionStart hook is added to the session context.
set -euo pipefail
shopt -s nullglob

RESEARCH_DIR="${RESEARCH_DIR:-research}"
PROMPTS_DIR="${CLAUDE_PLUGIN_ROOT}/prompts"

printf '\n===== research-workflow: research artifacts directory = %s/ =====\n' "$RESEARCH_DIR"

for f in "${RESEARCH_DIR}"/*.md; do
  [[ -f "$f" ]] || continue
  printf '\n===== %s =====\n' "$f"
  cat "$f"
done

printf '\n'
cat "${PROMPTS_DIR}/session-probe.md"
