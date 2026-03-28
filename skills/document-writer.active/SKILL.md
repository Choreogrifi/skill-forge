---
name: document-writer
skill-type: workflow
memory-file: workflow/document-writer.md
description: Guided workflow to create, review, update, or extend any document from a curated template library. Routes to the correct SME skill based on the user's selection. Invoke when the user wants to write, improve, or add to a document.
disable-model-invocation: true
---

# Document Writer

Presents a template and operation menu, collects the document subject, and routes to the appropriate SME skill. All file writes require explicit user approval of the target location before execution.

## Workflow

### 1. Collect Subject

Ask the user what the document is about:

```
What is the document subject or purpose?
(e.g. "a Node.js REST API for managing orders", "the checkout service architecture")
```

Hold the subject as context for the activated skill.

### 2. Select Operation

```
What would you like to do?

  1. Write a new document
  2. Review an existing document
  3. Update an existing document
  4. Add content to an existing document

Enter 1–4:
```

### 3a. New Document — Select Template

If the user selected 1:

```
Select a document template:

  1. Git README.md        — discoverable project readme optimised for GitHub/GitLab
  2. Mermaid diagram      — architecture, flow, sequence, or state diagram
  3. Other                — describe the document type you need

Enter 1–3:
```

- `1` → activate `write-readme`, pass the subject.
- `2` → activate `mermaid-drawer`, pass the subject.
- `3` → ask: "Describe the document type (e.g. runbook, API reference, onboarding guide, ADR)." Then activate `write-readme` with a generic document mode, or inform the user that this template is not yet available and suggest the closest match. Log the requested type for future template addition.

### 3b. Existing Document Operations

If the user selected 2 → activate `review-document`.
If the user selected 3 → activate `update-document`.
If the user selected 4 → activate `add-document`.

For operations 2–4, ask: `Path to the existing document:` before activating the skill.

### 4. Post-Operation

After the activated skill completes, ask:

```
Anything else? (select another operation or "done")
```

Return to Step 2 on any new request. Exit on "done".

## Guidelines

- **Never write files directly** — all file writes are delegated to the activated skill.
- **Subject carries through** — always pass the collected subject to the activated skill so it does not ask again.
- **Location approval is mandatory** — every skill that writes a file must confirm the target path with the user before writing. This is enforced in each sub-skill.
- **mermaid-drawer is external** — it is an existing skill; do not replicate its logic here.

## Related Skills

- `write-readme` — drafts a discoverable Git README.md from the 2026 template
- `mermaid-drawer` — generates Mermaid diagram code (existing skill)
- `review-document` — reviews any document against quality and structure standards
- `update-document` — modifies specific sections of an existing document with confirmation
- `add-document` — appends new sections or content to an existing document with confirmation
