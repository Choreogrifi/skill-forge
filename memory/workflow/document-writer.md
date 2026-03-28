---
skill: document-writer
skill-type: workflow
description: Router context — template selection and sub-skill delegation for document creation
last-updated: 2026-03-25
---

## Workflow Context

- Collects document subject from user before selecting template
- Routes to: `write-readme`, `update-document`, `add-document`, `review-document`, or `documenter`
- Confirms file location with user before any write
- All file writes require explicit user approval of the target path

## Template Types

- README → `write-readme`
- HLD / architecture doc → `documenter`
- ADR → `documenter`
- Update existing section → `update-document`
- Add new section → `add-document`
- Review quality → `review-document`
