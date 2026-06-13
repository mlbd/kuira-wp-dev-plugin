# Security Policy

This project is a Claude Code plugin: skills (Markdown), agent definitions, JSON
config, and shell **hook scripts**. The meaningful attack surface is the hook scripts
(they run shell commands on your machine) and the patterns the skills generate.

## Reporting a vulnerability

**Please do not open a public issue for security problems.** Instead, use GitHub's
private vulnerability reporting:

1. Go to the repository's **Security** tab → **Report a vulnerability**.
2. Describe the issue, affected file(s), and a reproduction.

We aim to acknowledge reports within a few days and to ship a fix or mitigation
promptly, crediting reporters who want it.

## What counts as a vulnerability here

- A **hook script** that can be made to execute unintended commands, leak data, or
  be bypassed (e.g. a `bash-guard` evasion, or `commit-gate` running attacker-controlled input).
- A **generated code pattern** in a skill that is insecure by default (e.g. a REST
  scaffold missing its `permission_callback`, an unescaped output template).
- A **permission or settings default** that grants more than it should.

## What does not

- WordPress core / third-party plugin vulnerabilities — report those upstream.
- Issues requiring the user to deliberately disable a safety guard (e.g. setting
  `KUIRA_COMMIT_GATE=0` then committing broken code).

## Hardening notes for users

- Hook scripts run with your shell's privileges. Review `hooks/scripts/*.sh` before
  installing if your threat model requires it — they are intentionally short and readable.
- The hooks **fail open** when a tool (`jq`, `php`, `phpcs`) is missing, so a missing
  dependency never blocks you — but it also means a guard can't inspect what it can't parse.
- Keep `GITHUB_TOKEN` (used by the optional GitHub MCP server) scoped minimally.
