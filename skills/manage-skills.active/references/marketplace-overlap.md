# Marketplace Plugin Overlap Registry

This file documents official marketplace plugins that overlap with custom skills.
Custom skills always take precedence. **Do NOT install any plugin listed as a conflict.**

---

## Conflict Matrix

| Custom Skill | Conflicting Plugin | Conflict Type | Action |
|---|---|---|---|
| `git-commit` | `commit-commands` | Full overlap — both automate git commit/push/PR workflows | **Do not install** |
| `security` | `security-guidance` | Full overlap — both enforce OWASP and GCP IAM security rules | **Do not install** |
| `engineer` | `feature-dev` | Partial overlap — feature-dev adds multi-agent orchestration | Avoid — custom skill preferred |
| `engineer` | `code-simplifier` | Partial overlap — code-simplifier focuses on refactoring only | Avoid — custom skill preferred |
| `architect` | `code-review` | Partial overlap — code-review automates PR review agents | Avoid — custom skill preferred |
| `tester` | `pr-review-toolkit` | Partial overlap — pr-review-toolkit automates PR-level test checks | Avoid — custom skill preferred |

---

## Safe to Install

These plugins provide capabilities not covered by any custom skill:

| Plugin | Provides | Notes |
|---|---|---|
| `pyright-lsp` | Python LSP / type checking in-editor | Already installed |
| `skill-creator` | Skill scaffolding and evaluation tooling | Complements `manage-skills` |
| `hookify` | Hook-based automation rules | No custom skill overlap |
| `claude-code-setup` | Automation recommendations for new projects | No custom skill overlap |
| `plugin-dev` | Plugin/hook/agent development tooling | No custom skill overlap |
| `frontend-design` | UI component generation | No custom skill overlap |
| `ralph-loop` | Recurring background loop automation | No custom skill overlap |
| `playground` | Experimental skill/prompt testing | No custom skill overlap |
| `*-lsp` (clangd, gopls, etc.) | Language server integrations | No custom skill overlap |

---

## Resolution Policy

When a newly published marketplace plugin overlaps with a custom skill:
1. Add it to the Conflict Matrix above with action **Do not install**.
2. If already installed, uninstall it: `/plugin uninstall <plugin-name>`.
3. Update this file and note the date.
