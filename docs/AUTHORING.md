# Authoring a skill or agent for this toolkit

This guide is for contributors adding to **kuira-wp-dev-plugin**. It captures the
conventions that keep the toolkit coherent and trustworthy. Run
`bash scripts/validate.sh` before opening a PR — CI runs the same checks.

## Repo layout (modular marketplace)

This repo is a marketplace of four plugins under `plugins/`:

- **kuira-wp-core** — build essentials + safety hooks (start here)
- **kuira-wp-quality** — testing, analysis, auditing (+ auditor agents)
- **kuira-wp-ship** — release, deploy, docs
- **kuira-wp-maintain** — modernization, debugging

A skill/agent/hook lives under its module: `plugins/<module>/skills/<name>/SKILL.md`,
`plugins/<module>/agents/<name>.md`, `plugins/<module>/hooks/`. Pick the module that
matches the lifecycle stage; if unsure, it's probably core or quality. Each plugin has
its own `.claude-plugin/plugin.json` (its `name` must equal the folder name) and the
marketplace lists them in `.claude-plugin/marketplace.json`.

## Skill vs. agent vs. hook — pick the right tool

- **Skill** (`plugins/<module>/skills/<name>/SKILL.md`) — a procedure Claude follows in
  the main conversation. Use for codegen, multi-step workflows, anything that writes files.
- **Agent** (`plugins/<module>/agents/<name>.md`) — a subagent with its own context and
  (usually) read-only tools. Use for **scans/reviews** that report without touching
  files (security, performance, a11y). Cheaper models (haiku) for traversal.
- **Hook** (`plugins/<module>/hooks/`) — deterministic shell that fires on a lifecycle
  event. Use for guards and on-save checks. Hooks must **fail open** and stay **low-noise**.
- **Cross-module references** (e.g. `wp-new` in core pointing at `wp-test` in quality):
  the referencing skill must **degrade gracefully** — generate from its own knowledge
  and tell the user which plugin to install, never block on a missing module.

## Skill conventions

Frontmatter (validated by CI):
```yaml
---
name: wp-foo            # MUST equal the folder name
description: >          # trigger-rich but accurate — this is how Claude decides to load it
  One-paragraph summary with the phrases a user would actually say.
  Note explicitly if the skill is opt-in.
allowed-tools: Read, Write, Bash, Glob
model: sonnet           # haiku for cheap scans, sonnet for codegen/judgment
---
```

Rules:
1. **`name` must match the folder.** CI fails otherwise.
2. **Opt-in by default.** Only `wp-context` auto-loads (via `paths:`). Action skills
   (codegen, setup) should trigger on explicit intent and **confirm before installing
   dependencies or changing config**. State this in the body.
3. **No proprietary content.** Use placeholders (`myplugin` / `my-plugin`), never a
   real commercial plugin's internals.
4. **Compose, don't duplicate.** If another skill already owns a concern, reference it
   (e.g. "follow `wp-endpoint` for the handler") instead of re-deriving it.
5. **Secure by default.** Any generated handler/query must include the right guards
   (nonce, capability, `permission_callback`, `$wpdb->prepare`, escaping).
6. **Avoid trigger collisions.** Before adding a skill, check existing
   `description:` lines for overlapping phrases; make yours distinct.

## Agent conventions

- Frontmatter `name` must equal the filename (minus `.md`).
- Default to **read-only** tools; end the prompt with "Return ONLY the report. Do not
  modify files." for auditors.
- Output a structured, prioritized report (severity buckets + a single top action).

## Hook conventions

- **Fail open:** a missing tool (`jq`, `php`, `phpcs`) must cause a silent skip, never
  a block. Probe parsers (the Windows Store `python3` is a non-functional stub).
- **Low-noise:** only speak when there's something actionable. Intrusive behavior
  (e.g. the commit gate) ships **off**, opt-in via an env var.
- **Portable:** target POSIX/Bash; avoid GNU-only or PCRE-only regex unless guarded.
  Keep scripts short and `shellcheck`-clean (severity error).

## Before you PR

```bash
bash scripts/validate.sh     # JSON, name↔path, frontmatter, shellcheck
```
- Update `CHANGELOG.md` under `## [Unreleased]`.
- Add your skill/agent to the README tables and the `wp-help` command map.
- If you touched a hook, test it by piping a sample JSON payload to the script.
