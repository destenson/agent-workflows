# Harness Compatibility: Claude Code and Codex

These plugins run under both [Claude Code](https://code.claude.com) and the [OpenAI Codex CLI](https://developers.openai.com/codex). The two tools share most of their plugin model — the same hook events, the same `hooks/hooks.json` schema, the same `skills/<name>/SKILL.md` format, and the same `${CLAUDE_PLUGIN_ROOT}` variable inside hook commands (Codex honors it as a legacy alias for its own `${PLUGIN_ROOT}`). Because of that overlap, the hook scripts, skills, and templates in this repo are shared, unmodified, by both tools.

The two places the tools differ are the plugin manifest and the marketplace file, so each plugin carries one of each:

| Concern | Claude Code | Codex |
| --- | --- | --- |
| Plugin manifest | `plugins/<p>/.claude-plugin/plugin.json` | `plugins/<p>/.codex-plugin/plugin.json` |
| Marketplace listing | `.claude-plugin/marketplace.json` | `.agents/plugins/marketplace.json` |
| Hooks | `plugins/<p>/hooks/hooks.json` (shared) | same file, same schema |
| Skills | `plugins/<p>/skills/<name>/SKILL.md` (shared) | same files, same format |

The Codex manifest needs an `interface` object (with at least `displayName`) that the Claude manifest does not, which is the main reason the two manifests are not identical. Codex's manifest validator also rejects a `hooks` field, so neither manifest declares hooks — both tools discover `hooks/hooks.json` by its default location.

## Installing in Codex

From a clone of this repo, add the repo-level marketplace and install a plugin:

```
codex
/plugins marketplace add ./.agents/plugins/marketplace.json
/plugins install agentic-workflow
```

The marketplace lists all five plugins (`agentic-workflow`, `embedded-target`, `research-workflow`, `sysadmin-workflow`, `c-suite`); install whichever you need.

## Commands are shipped as skills, not slash-command files

Codex plugins cannot bundle slash commands (its only custom-command path is user-level `~/.codex/prompts/*.md`, installed by hand outside any plugin). Rather than maintain separate command files for one tool, every workflow that used to be a slash command is shipped as a skill, which both tools invoke from the same `SKILL.md`:

- **Claude Code** invokes a plugin skill as `/<plugin>:<skill>` (current Claude Code merged custom commands into skills, so a skill *is* the slash command).
- **Codex** invokes the same skill as `@<skill>`.

There are no `commands/` directories in this repo; the `SKILL.md` is the single source for each workflow.

| Skill | Claude Code | Codex | Invocation |
| --- | --- | --- | --- |
| `project-docs-init` | `/agentic-workflow:project-docs-init` | `@project-docs-init` | manual only |
| `device-init` | `/embedded-target:device-init` | `@device-init` | manual only |
| `research-init` | `/research-workflow:research-init` | `@research-init` | manual only |
| `c-suite-init` | `/c-suite:c-suite-init` | `@c-suite-init` | manual only |
| `fleet-init` | `/sysadmin-workflow:fleet-init` | `@fleet-init` | manual only |
| `add-server` | `/sysadmin-workflow:add-server` | `@add-server` | manual only |
| `runbook` | `/sysadmin-workflow:runbook` | `@runbook` | manual only |
| `fleet-status` | `/sysadmin-workflow:fleet-status` | `@fleet-status` | manual or model-invoked |
| `incident` | `/sysadmin-workflow:incident` | `@incident` | manual or model-invoked |

"Manual only" skills carry `disable-model-invocation: true` in their frontmatter, so the model never triggers them on its own — they run only when you invoke them. These are the workflows that write or provision (the init scaffolders, `add-server`) or execute procedures against live hosts (`runbook`). `fleet-status` (read-only) and `incident` (reactive — you want it to engage when you report a problem) are left model-invocable. `disable-model-invocation` is a Claude Code frontmatter field; under Codex these skills are user-invoked via `@` regardless.

The `c-suite` plugin's `board-review` and the per-officer reviews were already skills and follow the same model.
