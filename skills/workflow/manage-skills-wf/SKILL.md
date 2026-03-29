---
name: manage-skills
skill-type: system
memory-file: system/manage-skills.md
description: Author new skills, detect skill gaps in the active session, and audit skill content quality. State transitions and symlink management are delegated to the skillforge CLI.
disable-model-invocation: true
---

# Manage Skills

Authors new skills, monitors sessions for skill gaps, and audits content quality.
State is managed by the `agents` CLI — never by this skill directly.

## CLI Delegation

For all state and symlink operations, emit the appropriate command and stop:

| Intent | Command |
|---|---|
| List all skills | `agents ls` |
| Activate a skill | `agents activate <name>` |
| Put skill in review | `agents review <name>` |
| Deactivate a skill | `agents deactivate <name>` |
| Decommission a skill | `agents rm <name>` |
| Fix symlink violations | `agents audit` |
| Environment check | `agents doctor` |

## Workflow Files

Load the relevant file only when the user's intent matches:

| File | Load when |
|---|---|
| `skill-create-wf.md` | User wants to create or scaffold a new skill |
| `skill-detect-wf.md` | Monitoring session for skill gaps (background protocol) |
| `skill-audit-wf.md` | Auditing skill content, frontmatter, or memory references |

## Guidelines

- Always write new skills to `~/.llm-assets/skills/` — never to the working directory.
- Never delete skill directories — decommission via `agents rm <name>`.
- After authoring a skill, always end with: `Run: agents activate <name>`
- Keep `SKILL.md` lean — move content >10 lines into `references/` or `*-wf.md` files.
- Memory scaffolding (stub creation, list, archive) is owned by `memory-manager`.

## References

- `references/marketplace-overlap.md` — plugin conflict data; check when creating skills that overlap with Claude plugins
- `references/mcp-playbook.md` — MCP server setup; read only when user asks about MCP infrastructure
