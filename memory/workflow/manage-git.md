---
skill: manage-git
skill-type: workflow
description: Router context — detects GitHub vs GitLab and delegates to correct sub-skill
last-updated: 2026-03-25
---

## Workflow Context

- Detects remote provider by running: `git remote get-url origin`
- GitHub remote → invoke `manage-github`
- GitLab remote → invoke `manage-gitlab`
- All destructive or remote-affecting actions require explicit user approval before execution
- Never force-push to `main` or `master` under any circumstances
