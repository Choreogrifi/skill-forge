---
name: update-document
skill-type: workflow
memory-file: workflow/update-document.md
description: Updates specific sections of an existing document based on user instructions. Presents a diff of all proposed changes for approval before writing. Activated by document-writer or invoke directly to revise any document.
disable-model-invocation: true
---

# Update Document

Applies targeted modifications to an existing document. Reads the current content, proposes precise changes as a diff, waits for explicit approval, and writes only on confirmation. Never rewrites sections beyond the scope of the user's instruction.

## Mandatory Tasks

1. **Read** the document at the provided path in full.
2. **Clarify** the update scope if the instruction is ambiguous — ask before drafting.
3. **Draft** only the changed sections; present as a before/after diff.
4. **Confirm** with the user before writing.
5. **Write** on approval; report the outcome.

## Output Format for Confirmation

```
Proposed changes to: <path>
────────────────────────────
Section: <heading>

BEFORE:
  <original content>

AFTER:
  <updated content>

────────────────────────────
Apply these changes? (yes / edit / cancel)
```

If multiple sections are affected, show each as a separate before/after block in sequence.

## Standards

- **Minimal footprint:** Change only what the user asked to change. Do not reformat, reword, or improve adjacent content unless explicitly requested.
- **Preserve structure:** Do not alter heading levels, section order, or existing markdown formatting outside the changed section.
- **One approval covers all changes:** Present all proposed changes together in a single confirmation — do not prompt per section.

## Constraints

- **Confirm before every write** — no exceptions.
- **Never delete sections** unless the user explicitly requests removal.
- **Never change file location** — updates are always written back to the original path.
