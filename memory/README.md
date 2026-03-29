# Memory

Memory files let your AI assistant remember things about you and your work across sessions.

When you tell the AI "I prefer TypeScript over JavaScript" or "my default branch is main", that preference can be saved to a memory file. The next time you start a session, the AI reads that file and already knows — you do not have to repeat yourself.

---

## Memory groups

| Directory | Loaded when | Unloaded when | Contents |
|---|---|---|---|
| `sme/` | SME skill invoked | `/clear` or session end | Domain preferences and standards for that skill |
| `workflow/` | Workflow skill invoked | `/clear` or session end | Routing context and operational conventions |

Each memory file is linked to one skill via the `skill:` frontmatter field. When a skill is deactivated, `memory-wf` offers to archive its memory file (`<name>.archived.md`). On reactivation, the archived file is offered for restore.

---

## Memory vs References

**Memory files** contain things that change as you work: your preferences, your project conventions, decisions you've made. They are personalised to you.

**Reference files** (in `skills/*/references/`) contain static knowledge that does not change unless the tool's knowledge changes: command lists, checklists, templates. They are the same for all users.

If you would update it when your project changes → memory.
If you would update it when the tool's knowledge changes → reference.

---

## Why memory size matters

Every word loaded into an AI session costs tokens — and tokens cost money. Memory files are loaded when their skill is invoked. Keep them focused:

- Stick to facts the AI genuinely needs to work effectively with you
- Remove facts that are no longer true (or archive them with a comment)
- Move long domain-specific content to a reference file instead

A well-organised memory setup means the AI loads only what it needs. A bloated one loads everything and costs far more.

---

## How to personalise your memory

After install, replace the `<PLACEHOLDER>` values in the shared memory files:

```bash
open ~/.skillforge/memory/shared/workspace-conventions.md
```

Use the `memory-manager-wf` skill inside your AI session to update memory files with confirmation:

```
Activate memory-manager-wf  →  "Remember that I use main as my default branch"
```

---

## Memory file format

Each memory file has a short frontmatter block followed by bullet-point facts:

```markdown
---
skill: git-sme
skill-type: sme-persona
description: Git conventions for this project
last-updated: 2026-03-28
---

## Branching Conventions
- Default branch: main
- Feature branches: feat/<ticket>-<description>
```

Maximum 40 lines per file. If a file grows beyond that, split it into two scoped files.

Use the templates in `../templates/memory/` when creating new memory files.
