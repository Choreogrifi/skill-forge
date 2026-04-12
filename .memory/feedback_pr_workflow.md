---
name: PR Workflow
description: All changes to skill-forge repos must be raised as PRs for user approval, not committed directly to main
type: feedback
---

Always raise a PR for changes to `Choreogrifi/skill-forge` and `Choreogrifi/homebrew-skill-forge` instead of committing directly to `main`.

**Why:** User wants to review and approve changes before they land on main.

**How to apply:** After staging changes locally, create a feature branch, push it, and open a PR via `gh pr create`. Do not push directly to `main`.
