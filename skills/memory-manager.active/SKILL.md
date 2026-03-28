---
name: memory-manager
skill-type: system
memory-file: system/memory-manager.md
description: Detects memory-change intent in user input and updates the correct workspace memory file with explicit user approval. Invoke directly or trigger automatically from natural language patterns.
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
