# Agent Workflows

A small marketplace of plugins that make agent-driven work durable across sessions. Each plugin encodes one operating loop — general development, embedded-target debugging, research, fleet administration, or executive review — as a set of session hooks, skills, and templates, so that design intent, assumptions, and lessons survive instead of being re-derived every session.

The plugins run under both [Claude Code](https://code.claude.com) and the [OpenAI Codex CLI](https://developers.openai.com/codex). See [COMPATIBILITY.md](COMPATIBILITY.md) for how the dual-harness support works and what differs between the two tools.

For the ideas these workflows are built on, read [PRINCIPLES.md](PRINCIPLES.md); for the longer-form rationale and the relationship between the workflow documents, read [ABOUT.md](ABOUT.md).

## The plugins

| Plugin | What it does |
| --- | --- |
| `agentic-workflow` | Base agentic development loop. Loads four durable artifacts (SPEC / ASSUMPTIONS / DECISIONS / LESSONS) at session start, re-injects standing rules every turn, warns on complexity-budget violations, and gates session exit on a distillation decision. Ships the design-interview, assumption-audit, spike, bug-investigation, retrospective, and entropy-pass skills. |
| `embedded-target` | Extends the base loop for remote embedded Linux targets (e.g. Jetson). Loads `DEVICE.md`, scaffolds a build-deploy-run-collect harness, a repro library, and fault-injection templates, and ships the reproducible and instrument-and-wait debug-loop skills. |
| `research-workflow` | Self-contained research loop. Loads the research artifacts (abstract / proposal / experiments / results), re-injects research standing rules, and ships the problem-statement, literature-scan, gap-analysis, proposal, experiment-design, preregistration, results-memo, negative-results, and decision-memo skills. |
| `sysadmin-workflow` | Administering and troubleshooting remote fleets. Loads `FLEET.md` plus the INCIDENTS / CHANGELOG / RUNBOOKS journals, re-injects ops standing rules, advises on destructive commands with an audit trail, and ships the troubleshooting-loop, fleet-onboard, incident-record, and runbook-capture skills. |
| `c-suite` | Convenes executive-officer review lenses (CEO / CFO / COO / CTO / CMO / CLO) on one decision and preserves their disagreement instead of averaging it away. Keeps a governance spine (CHARTER / STRATEGY / BOARD) and ships the board-review workflow plus per-officer review skills. |
| `handoff` | Standalone session handoff. Loads a pending `HANDOFF.md` at session start so a new session resumes where the last left off, gives a non-blocking reminder to record unfinished and newly-discovered work before wrapping up, and ships the handoff skill that writes, updates, and clears the rolling handoff. Independent of the other plugins. |

## Repository layout

```
.claude-plugin/marketplace.json     Claude Code marketplace listing
.agents/plugins/marketplace.json     Codex marketplace listing
plugins/<plugin>/
  .claude-plugin/plugin.json         Claude Code manifest
  .codex-plugin/plugin.json          Codex manifest
  hooks/hooks.json                   session/turn/tool/stop hooks (shared by both tools)
  scripts/                           hook implementations
  skills/<name>/SKILL.md             invocable skills (shared by both tools)
  templates/                         durable-artifact scaffolding
```

## Installing

### Claude Code

```
/plugin marketplace add destenson/agent-workflows
/plugin install agentic-workflow@agent-workflows
```

### Codex

```
/plugins marketplace add ./.agents/plugins/marketplace.json
/plugins install agentic-workflow
```

Install whichever plugins you need; they are independent (`embedded-target` is a complement to `agentic-workflow`, not a hard dependency). Each workflow is a skill, invoked as `/<plugin>:<skill>` in Claude Code or `@<skill>` in Codex — see [COMPATIBILITY.md](COMPATIBILITY.md) for the full list and which run manual-only.

## Status

These workflows describe a working approach, not settled doctrine. Several claims in the workflow documents are explicitly hypotheses from limited experience, and the hooks and gates should be refined against real use wherever they produce more friction than signal.
