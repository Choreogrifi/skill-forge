---
name: review-document
skill-type: workflow
memory-file: workflow/review-document.md
description: Reviews any document against structure, clarity, completeness, and discoverability standards. Returns a scored report with prioritised improvement recommendations. Activated by document-writer or invoke directly to review any markdown or text document.
disable-model-invocation: true
---

# Review Document

Reads an existing document, evaluates it against quality standards appropriate for its type, and returns a structured review report with scored findings and actionable recommendations. Does not modify files.

## Focus

Apply editorial and technical writing standards: clarity, completeness, structure, discoverability (for public-facing docs), and consistency. Tailor the review criteria to the document type (README, runbook, ADR, diagram spec, etc.).

## Mandatory Tasks

1. **Identify** the document type from its content and path (README, ADR, runbook, diagram, onboarding guide, etc.).
2. **Read** the document in full. Read `references/review-checklist.md` to load the criteria relevant to the detected type.
3. **Score** each criterion and produce a structured report.

## Output Format

```
Document Review: <filename>
Type detected:   <README / ADR / runbook / other>
Overall score:   <n>/10
────────────────────────────────────────
CRITICAL  (must fix before publishing)
  [ ] <finding> — <recommendation>

MAJOR     (significantly impacts quality)
  [ ] <finding> — <recommendation>

MINOR     (improvements worth making)
  [ ] <finding> — <recommendation>

PASSED
  [x] <criterion> — looks good
────────────────────────────────────────
Summary: <2–3 sentence overall assessment>
```

## Standards

- Be specific — every finding must name the exact section or line it applies to.
- Be actionable — every finding must include a concrete recommendation, not just a complaint.
- Score honestly — a well-written document should score 8+; do not inflate scores.
- Discoverability check applies to all public-facing documents (README, wiki pages): evaluate keyword density, heading structure, and meta description quality.

## Constraints

- **Read only** — never modify, overwrite, or suggest writing a new file. Findings are advisory.
- **No assumptions** — only review what is present in the document; do not penalise for content that may intentionally be absent (e.g. a minimal README for a private repo).

## References

- `references/review-checklist.md` — per-type review criteria with scoring weights; read during the Score step
