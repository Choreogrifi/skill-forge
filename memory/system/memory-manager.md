---
skill: memory-manager
skill-type: system
description: Memory update context — trigger patterns, target resolution, write rules
last-updated: 2026-03-25
---

## Trigger Patterns

Activate when user input contains:
- "remember that...", "note that...", "going forward..."
- "update my memory / profile / preferences..."
- "forget...", "remove from memory...", "I no longer..."
- "I prefer...", "from now on...", "always..."

## Target Resolution

| User Intent | Target File |
|---|---|
| Personal preference / working style | `shared/identity.md` |
| Workspace convention (naming, tooling) | `shared/workspace-conventions.md` |
| SME domain knowledge update | `sme/<skill-name>.md` |
| Workflow-specific context | `workflow/<skill-name>.md` |
| New symlink discovered | `shared/symlink-registry.md` |

## Write Rules

- Always show a before/after diff and wait for explicit approval
- Never delete content — archive with `<!-- archived: YYYY-MM-DD: <reason> -->` comment
- Update `last-updated` in frontmatter on every approved write
- If the target file does not exist: propose creating it with correct frontmatter before writing
- `shared/identity.md` changes require the highest scrutiny — always confirm intent before drafting
