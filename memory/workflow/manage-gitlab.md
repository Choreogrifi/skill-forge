---
skill: manage-gitlab
skill-type: workflow
description: GitLab operations context — CLI tools, approval gate, MR conventions
last-updated: 2026-03-25
---

## Workflow Context

- Uses `git` for local operations, `glab` for GitLab platform operations
- Every proposed action is presented as a dry-run summary before execution
- Nothing executes without explicit user approval
- References: `~/.llm-assets/skills/manage-gitlab.active/references/gitlab-operations.md`

## MR Standards

- MR title: conventional commit style (`feat:`, `fix:`, `chore:`)
- MR body: summary, test plan, checklist
- Squash merge preferred for feature branches
- Pipeline must pass before merge — no pipeline bypass
