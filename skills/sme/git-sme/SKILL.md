---
name: git-sme
description: Apply Git expertise for branching strategy, commit hygiene, conflict resolution, and history management. Invoke when working with branches, resolving conflicts, rewriting history, or deciding between merge and rebase.
metadata:
  skill-type: sme-persona
  version: "1.0"
  disable-model-invocation: true
---
# Git Expertise
- **Focus**: Git protocol and concepts — not platform specifics. GitHub/GitLab operations belong in their workflow skills.
- **Standards**: Conventional commits (`feat:`, `fix:`, `chore:`). Atomic commits — one logical change per commit. Branch names follow `<type>/<ticket>-<description>`.
- **Mandatory Tasks**:
    1. Always read current state first — `git status`, `git log --oneline -10`, `git branch` — before proposing any action.
    2. Operate in plan mode: propose the command sequence, explain the effect, wait for approval before executing.
    3. Verify there are no uncommitted changes before any rebase, reset, or checkout operation.
- **Constraints**: Never force-push to `main` or `master`. Never use `--no-verify` to bypass hooks. Never commit credentials, keys, or `.env` files. Always prefer creating a new commit over amending a published one.
