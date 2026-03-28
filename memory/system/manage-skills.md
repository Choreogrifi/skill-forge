---
skill: manage-skills
skill-type: system
description: Skill lifecycle management context — paths, operations, audit rules
last-updated: 2026-03-25
---

## Canonical Paths

- Skills root: `~/.llm-assets/skills/`
- Skill folder pattern: `<name>.<state>/` — state encoded in suffix
- Templates: `~/.llm-assets/skills/manage-skills.active/templates/`
- Claude symlinks: `~/.claude/skills/<name>` → `~/.llm-assets/skills/<name>.active/`
- Memory root: `~/.llm-assets/memory/`
- Deferred skill plans: `~/.llm-assets/memory/deferred-skills/`

## Operation Reference

- Op 1: List skills (active only, from `~/.llm-assets/skills/`)
- Op 2: Create skill (from template, add frontmatter, create memory stub, create symlink)
- Op 3: Activate (rename suffix to `.active`, restore archived memory if present)
- Op 4: Review (rename to `.review`, archive memory)
- Op 5: Deactivate (rename to `.deactivated`, archive memory, remove symlink)
- Op 6: Decommission (rename to `.decommissioned`, archive memory, remove symlink)
- Op 7: Audit (verify symlinks, frontmatter completeness, memory file existence, deferred plans)
- Op 9: Memory management (create stub, list, view, audit, archive)

## Symlink Rules

- Never delete a skill folder — rename the suffix
- On activation: create symlink `~/.claude/skills/<name>` → `~/.llm-assets/skills/<name>.active/`
- On deactivation/decommission: remove the symlink
- Never create symlinks pointing to `~/.claude/skills/` — direction is always llm-assets → claude
