---
skill: review-document
skill-type: workflow
description: Document quality review — scoring, criteria, improvement recommendations
last-updated: 2026-03-25
---

## Workflow Context

- Reads document in full before scoring
- Identifies document type from content and path (README, ADR, runbook, HLD, etc.)
- Loads relevant criteria from `references/review-checklist.md`
- Returns scored report with actionable recommendations — does not modify files

## Review Dimensions

- Structure and completeness
- Clarity and readability
- Technical accuracy
- Discoverability (for public-facing docs)
- Consistency with workspace documentation standards
