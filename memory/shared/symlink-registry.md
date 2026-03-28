---
type: shared
description: Known symlinks in this workspace — read before any directory scan to avoid double-reads
last-updated: 2026-03-25
---

## Rule

Before iterating any directory, check this registry. If the target path is listed
as a symlink destination, skip it — read from the canonical source only.

## Registry

| Symlink Path | Canonical Source | Notes |
|---|---|---|
| `~/.claude/skills/<name>` | `~/.llm-assets/skills/<name>.active/` | One symlink per active skill |
| `~/.claude/CLAUDE.md` | `~/.llm-assets/model.md` | Auto-synced on model.md write |

## Scan Rules

- When scanning skills: use `~/.llm-assets/skills/` — never `~/.claude/skills/`
- When reading the persona/model: use `~/.llm-assets/model.md`
- When scanning memory: use `~/.llm-assets/memory/` — no known symlinks here

## Unregistered Symlink Procedure

If a symlink is encountered that is not listed above:
1. Stop the scan immediately
2. Flag the path to the user: `"Unregistered symlink detected: <path>. Proceed? (yes / no)"`
3. On approval: add it to this registry before continuing
