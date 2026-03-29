---
name: memory-manager-wf
description: Detects memory-change intent in user input and updates the correct workspace memory file with explicit user approval. Invoke directly or trigger automatically from natural language patterns.
metadata:
  skill-type: system
  version: "1.0"
  memory-file: system/memory-manager.md
  disable-model-invocation: true
---

# Memory Manager

Detects when the user wants to record, update, or remove a fact from workspace memory.
Identifies the correct target file, proposes the exact change as a before/after diff,
and writes only on explicit approval.

## Trigger Patterns

Activate when user input contains phrases such as:
- "remember that...", "note that...", "going forward..."
- "update my memory / profile / preferences..."
- "forget...", "remove from memory...", "I no longer..."
- "I prefer...", "from now on...", "always...", "never..."

## Workflow

### 1. Classify the Memory

Determine what type of fact the user wants to record:

| User Intent | Target File |
|---|---|
| Personal preference, working style, governance | `~/.llm-assets/memory/shared/identity.md` |
| Workspace convention (naming, tooling, GCP registry) | `~/.llm-assets/memory/shared/workspace-conventions.md` |
| New symlink discovered | `~/.llm-assets/memory/shared/symlink-registry.md` |
| SME domain knowledge or standard | `~/.llm-assets/memory/sme/<skill-name>.md` |
| Workflow-specific context or convention | `~/.llm-assets/memory/workflow/<skill-name>.md` |

If the target file is ambiguous, ask the user to confirm the category before proceeding.

### 2. Read the Target File

Read the full content of the target file before drafting any change.

### 3. Propose the Change

Present an explicit before/after diff:

```
Target: ~/.llm-assets/memory/shared/identity.md

BEFORE (line N):
  - <existing content>

AFTER:
  - <existing content>
  - <new entry>

Approve? (yes / no)
```

For removals, archive the line rather than deleting it:
```
<!-- archived: YYYY-MM-DD: <reason> --> - <old content>
```

### 4. Write on Approval

- Write the change to the target file on explicit "yes"
- Update the `last-updated` field in the frontmatter to today's date
- Confirm the write: `"Memory updated: <target file>"`

## Constraints

- Never write without showing the diff and receiving explicit approval
- Never delete memory content — archive it with a comment instead
- `shared/identity.md` changes require extra caution — always re-read the proposed
  change aloud in plain language before asking for approval
- If the target file does not exist, propose creating it with the correct frontmatter
  schema before writing any content
- Maximum body length per memory file: 40 lines — if exceeded, propose splitting into
  two scoped files

## Memory Scaffolding Operations

Invoke when the user asks to scaffold, list, view, or archive memory files (rather
than update their content).

### Create Memory Stub

1. Ask which skill this memory file belongs to (use skill name).
2. Determine group from the skill's `skill-type`: `sme-persona` → `sme/`, `workflow` → `workflow/`, `system` → `system/`.
3. Scaffold at `~/.llm-assets/memory/<group>/<skill-name>.md`:

```markdown
---
skill: <skill-name>
skill-type: <skill-type>
description: <one-line — what context this file provides>
last-updated: YYYY-MM-DD
---

<!-- Add bullet-point facts below. Max 40 lines. -->
```

4. Update the skill's `SKILL.md` frontmatter to add `memory-file: <group>/<skill-name>.md` if absent.
5. Confirm the created path.

### List Memory Files

1. Use Glob `~/.llm-assets/memory/**/*.md` — exclude `deferred-skills/` and `*.archived.md`.
2. For each file, read frontmatter only (first block between `---` delimiters).
3. Present a table:

```
Group          | File                              | Skill
-------------- | --------------------------------- | -----
```

### View Memory File

Ask: `Which memory file? (path relative to ~/.llm-assets/memory/ or skill name)`
Read and display the full file.

### Archive Memory File

Use when a skill is deactivated or decommissioned:

1. Identify memory files associated with the skill (via `memory-file` frontmatter).
2. Prompt: `Archive memory file <path>? (yes / no)`
3. On yes: rename `<name>.md` → `<name>.archived.md`
4. On reactivation: check for `<skill-name>.archived.md` — offer to restore if found.
