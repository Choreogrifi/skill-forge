---
skill: manage-github
skill-type: workflow
description: GitHub operations context — CLI tools, approval gate, branch conventions
last-updated: 2026-03-25
---

## Workflow Context

- Uses `git` for local operations, `gh` for GitHub platform operations
- Every proposed action is presented as a dry-run summary before execution
- Nothing executes without explicit user approval
- References: `~/.llm-assets/skills/manage-github.active/references/github-operations.md`

## Branch Conventions

- Feature branches: `feat/<ticket>-<short-description>`
- Fix branches: `fix/<ticket>-<description>`
- Never commit directly to `main` or `master`

## PR Standards

- PR title: conventional commit style (`feat:`, `fix:`, `chore:`)
- PR body: summary, test plan, checklist
- Squash merge preferred for feature branches
