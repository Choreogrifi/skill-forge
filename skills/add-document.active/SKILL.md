---
name: add-document
skill-type: workflow
memory-file: workflow/add-document.md
description: Appends new sections, content blocks, or entries to an existing document. Shows the proposed addition in context before writing. Activated by document-writer or invoke directly to extend any document.
disable-model-invocation: true
---

# Add Document

Extends an existing document with new content. Reads the current file, determines the correct insertion point, shows the proposed addition in context, and writes only after explicit user approval.

## Mandatory Tasks

1. **Read** the document at the provided path in full.
2. **Collect** what content to add and where it should appear (after which section, at the end, etc.).
3. **Propose** the addition shown in context — the section it follows and the new content.
4. **Confirm** with the user before writing.
5. **Write** on approval; report the outcome.

## Output Format for Confirmation

```
Proposed addition to: <path>
─────────────────────────────
Insertion point: after "<section heading>" / at end of file

... existing content above ...

--- NEW CONTENT BEGINS ---
<full new section or content block>
--- NEW CONTENT ENDS ---

... existing content below (if any) ...

─────────────────────────────
Add this content? (yes / edit / cancel)
```

## Standards

- **Position matters:** Always show the surrounding context so the user can verify the insertion is in the right place.
- **Respect document conventions:** Match the heading level, tone, and formatting style already present in the document.
- **One addition per confirmation:** If adding multiple unrelated sections, confirm each separately.

## Constraints

- **Confirm before every write** — no exceptions.
- **Append-only by default** — do not modify existing content unless the user explicitly requests it. If modification is needed, delegate to `update-document`.
- **Never change file location** — content is always added to the original path.
