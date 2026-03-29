# Memory Create Subflow

Scaffolds a new memory file for a skill from the appropriate template.

## Workflow

### 1. Identify the Skill

Ask:
```
Which skill needs a memory file?
(Enter the skill name, e.g. git-sme, terraform-wf)
```

Determine the group from the skill's `skill-type`:
- `sme-persona` → `sme/`
- `workflow` / `system` → `workflow/` or `system/`

If the group is unclear, ask the user to confirm.

### 2. Check for Existing File

Check `${SKILLFORGE_DIR}/memory/<group>/<skill-name>.md`.

If it already exists: show its content and ask:
```
A memory file already exists for this skill.
  1. Edit the existing file (use memory-wf update flow)
  2. View only
  3. Cancel

Enter 1–3:
```

### 3. Choose Template

Select the correct template:
- `sme/` → `templates/memory/sme-memory.md`
- `workflow/` or `system/` → `templates/memory/workflow-memory.md`

### 4. Propose the Stub

Present the scaffolded file content:

```
New memory file: ${SKILLFORGE_DIR}/memory/<group>/<skill-name>.md
────────────────────────────────────────────────────────────────
---
skill: <skill-name>
skill-type: <skill-type>
description: <fill in>
last-updated: <today>
---

<!-- Add bullet-point facts below. Max 40 lines. -->

Create this file? (yes / cancel)
```

### 5. Write on Approval

- Write the stub to `${SKILLFORGE_DIR}/memory/<group>/<skill-name>.md`
- Update the skill's `SKILL.md` frontmatter to add `memory-file: <group>/<skill-name>.md` if absent
- Confirm: `"Memory stub created: <path>"`

## Guidelines

- Never overwrite an existing memory file — redirect to the update flow.
- The stub is intentionally empty — the user fills it in using the `memory-wf` update flow.
