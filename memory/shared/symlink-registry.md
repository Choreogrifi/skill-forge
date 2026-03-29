<!-- EDIT THIS FILE — update paths to match your actual install location -->
---
type: shared
description: Known symlinks in this workspace — read before any directory scan to avoid double-reads
last-updated: {{YYYY-MM-DD}}
---

## Rule

Before iterating any directory, check this registry. If the target path is listed
as a symlink destination, skip it — read from the canonical source only.

## Registry

| Symlink Path | Canonical Source | Notes |
|---|---|---|
| `~/.claude/skills/<name>` | `${SKILLFORGE_DIR}/skills/<name>.active/` | One symlink per active skill |
| `~/.claude/CLAUDE.md` | `${SKILLFORGE_DIR}/model.md` | Auto-synced on model.md write |
| `~/.gemini/skills/<name>` | `${SKILLFORGE_DIR}/skills/<name>.active/` | If Gemini is a configured LLM target |
| `~/.gemini/GEMINI.md` | `${SKILLFORGE_DIR}/model.md` | If Gemini is a configured LLM target |

> `${SKILLFORGE_DIR}` is set at install time and written to `~/.skillforge/config.yaml`.
> Default: `~/.skillforge`

## Scan Rules

- When scanning skills: use `${SKILLFORGE_DIR}/skills/` — never `~/.claude/skills/`
- When reading the persona/model: use `${SKILLFORGE_DIR}/model.md`
- When scanning memory: use `${SKILLFORGE_DIR}/memory/`

## Unregistered Symlink Procedure

If a symlink is encountered that is not listed above:
1. Stop the scan immediately
2. Flag the path to the user: `"Unregistered symlink detected: <path>. Proceed? (yes / no)"`
3. On approval: add it to this registry before continuing
