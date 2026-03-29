# Memory Audit Subflow

Reviews all memory files for staleness, bloat, and orphaned references.
Reports issues without making changes — changes require explicit user approval.

## Workflow

### 1. Discover Memory Files

Use Glob `${SKILLFORGE_DIR}/memory/**/*.md` — exclude `*.archived.md`.
For each file, read the frontmatter block only (content between `---` delimiters).

### 2. Run Checks

For each memory file, check:

**Staleness**
- Read `last-updated` field
- If older than 90 days from today → `STALE` (flag for review)

**Bloat**
- Count non-frontmatter, non-comment lines
- If count > 40 → `BLOATED` (suggest splitting into two scoped files)

**Orphan check**
- Verify that at least one active skill references this file via `memory-file:` frontmatter
- If no active skill references it → `ORPHANED` (candidate for archiving)

**Broken reference**
- For each skill's `memory-file:` field: check the target path exists
- If missing → `BROKEN REFERENCE` (on the skill side)

### 3. Report

Present a summary table:

```
Memory Audit Report  (<date>)
─────────────────────────────
File                           | Status   | Issue
------------------------------ | -------- | ------
sme/terraform.md               | STALE    | Last updated 120 days ago
workflow/content.md            | OK       |
shared/identity.md             | BLOATED  | 52 lines (limit: 40)
sme/legacy-skill.md            | ORPHANED | No active skill references this file

Skills with broken memory-file references:
  skills/sme/old-sme/SKILL.md → memory-file: sme/missing.md (not found)
```

### 4. Propose Actions

For each flagged item, offer:
- STALE: "Update or confirm last-updated date"
- BLOATED: "Split into two scoped files"
- ORPHANED: "Archive as `<name>.archived.md`"
- BROKEN REFERENCE: "Remove `memory-file:` from SKILL.md or create the missing file"

All proposed actions require explicit user approval before execution.

## Guidelines

- Read-only until the user approves a specific action.
- Never delete memory files — archive them with `.archived.md` suffix.
- Run this subflow periodically (recommended: monthly) to keep memory lean.
