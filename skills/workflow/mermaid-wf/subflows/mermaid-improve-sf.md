# Mermaid Improve Subflow

Self-discovery workflow: audits all Mermaid content in the repository, generates an
improvement plan, and — on user approval — creates a PR for review.

## When to Use

Invoke when the user asks to "improve", "audit", or "self-discover" mermaid diagrams,
or when `mermaid-wf` is invoked with no specific diagram target.

## Workflow

### 1. Discover Mermaid Content

Use Glob to find all files containing Mermaid code blocks:

```
Pattern: **/*.md
Search within results for: ```mermaid
```

List all files found with the count of Mermaid blocks per file.

### 2. Audit Each Diagram

For each discovered diagram, activate `mermaid-read-sf` in review mode.
Collect all FAIL and WARN findings into a consolidated list.

### 3. Generate Improvement Plan

Present the plan as a structured document:

```
Mermaid Improvement Plan
────────────────────────
Files reviewed: <N>
Diagrams reviewed: <N>
Issues found: <errors> errors, <warnings> warnings

Proposed changes:
  File: <path>
  Diagram: <type> (line <N>)
  Issue: <description>
  Fix: <proposed change>

  ...

Proceed?
  1. Accept all — generate fixes and create PR
  2. Select specific fixes
  3. Save plan only (no edits)
  4. Discard

Enter 1–4:
```

### 4. Apply Fixes on Approval

For each accepted fix:
- Apply the correction using `mermaid-write-sf`
- Show a before/after diff before writing

### 5. Create Pull Request

After all fixes are applied, activate `git-wf` with:
```
Create a pull request for the Mermaid improvements.
Branch: feat/improve-mermaid-diagrams
Title: docs(diagrams): improve Mermaid diagram quality
Body: list all files changed and the issues resolved
```

### 6. Confirm

```
PR created: <url>
Files modified: <list>
```

## Guidelines

- Never apply fixes without showing before/after diff and receiving approval.
- The PR must include a description of every change for the reviewer to evaluate.
- If no issues are found, report: "All diagrams pass review. No changes needed."
