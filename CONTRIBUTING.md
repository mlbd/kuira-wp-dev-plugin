# Contributing to Kuira WP Dev Plugin

Thanks for your interest in improving this plugin! It's a small, dependency-free
collection of Claude Code skills, agents, and hooks for WordPress development, so
contributing is mostly editing Markdown and JSON.

## Ways to contribute

- **Improve a skill** — sharpen the WPCS rules in `wp-context`, add WooCommerce/HPOS
  patterns, extend the scaffold output in `wp-scaffold`, etc.
- **Add a security check** — new heuristics in `wp-security-audit` or the
  `wp-security-auditor` agent.
- **Harden the hooks** — `hooks/scripts/*.sh` should behave well on macOS, Linux,
  and Windows (Git Bash). Cross-platform fixes are very welcome.
- **Docs** — clarify the README, fix typos, add examples.

## Project layout

```
.claude-plugin/   plugin + marketplace manifests
skills/           one folder per skill, each with a SKILL.md (YAML frontmatter + body)
agents/           one Markdown file per subagent (YAML frontmatter + system prompt)
hooks/            hooks.json + Bash scripts
.mcp.json         MCP server config
settings.json     default model + permissions
```

## Conventions

- **Skills/agents** use YAML frontmatter. Keep `description` trigger-rich (it's how
  Claude decides when to load the skill) but accurate — don't over-claim.
- **No private/proprietary content.** Do not commit internal details of any
  commercial plugin (real table names, confirmed-bug notes, private slugs). Use
  generic placeholders like `myplugin` / `my-plugin`.
- **Hooks must fail open.** A missing tool (`jq`, `phpcs`) should cause the hook to
  skip silently, never to block the user's work.
- **Shell scripts**: target POSIX/Bash, avoid GNU-only or PCRE-only features unless
  guarded. Test under Git Bash if you can.

## Making a change

1. Fork and create a branch: `git checkout -b improve-wp-context`
2. Make your edit. If you touched a hook script, run it locally with a sample JSON
   payload on stdin to confirm it behaves.
3. Update `CHANGELOG.md` under an `## [Unreleased]` heading.
4. Open a PR describing **what** changed and **why**, and how you verified it.

## Testing your changes in Claude Code

Install your fork locally and reload:

```bash
git clone https://github.com/<you>/kuira-wp-dev-plugin ~/.claude/plugins/kuira-wp-dev-plugin
# then in Claude Code:
/plugin
```

Trigger the skill/agent you changed and confirm it loads and behaves as expected.

## Code of conduct

Be respectful and constructive. We follow the spirit of the
[Contributor Covenant](https://www.contributor-covenant.org/).

By contributing, you agree your contributions are licensed under the project's
[GPL-2.0-or-later License](LICENSE).
