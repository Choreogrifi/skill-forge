---
name: <name>
skill-type: workflow
memory-file: workflow/<name>.md
description: <One-line summary of what the workflow does and the outcome it produces>. Invoke when <specific user intent or trigger scenario>.
disable-model-invocation: true
---

# <Workflow Title>

<Brief paragraph describing what this workflow automates, why it exists, and what problem it solves.>

## Workflow

### 1. <First Step — Gather / Inspect>
<Instructions for what information to collect or inspect before acting>

### 2. <Second Step — Process / Draft>
<Instructions for what to compute, generate, or prepare>

### 3. <Third Step — Confirm with User>
Present the result to the user for approval before taking any irreversible action. Do not proceed without explicit confirmation.

### 4. <Fourth Step — Execute>
Upon user approval:
- <Action 1>
- <Action 2>
- Verify success with a final status check.

## Guidelines
- **Never act silently:** Always present a summary and wait for approval before irreversible actions.
- **Respect scope:** Only act on what the user explicitly requested — do not expand scope.
- <Additional constraint specific to this workflow>

## References
<!-- Optional. List files to read lazily — only when a step needs them.
     Store lookup tables, config schemas, or large reference docs in references/<name>.md, not inline here.
     Example:
       - `references/valid-targets.md` — allowlist of deployment targets; read during Step 2
       - `references/rollback-runbook.md` — recovery steps; read only if execution fails
     Remove this section if no reference files are needed. -->
