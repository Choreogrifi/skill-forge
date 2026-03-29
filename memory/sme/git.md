---
skill: git-sme
skill-type: sme-persona
description: Git conventions for this workspace — branching, commit style, merge strategy
last-updated: 2026-03-28
---

## Branching

- Default branch: `main`
- Branch naming: `<type>/<ticket>-<description>` (e.g. `feat/SF-42-add-toggle-subflow`)
- Types: `feat`, `fix`, `chore`, `docs`, `refactor`, `test`

## Commit Style

- Conventional commits: `feat:`, `fix:`, `chore:`, `docs:`, `refactor:`, `test:`
- Atomic commits — one logical change per commit
- Never commit credentials, `.env` files, or generated binaries

## Merge Strategy

- Prefer rebase over merge for feature branches before PR
- Squash only when history is noise (e.g. fixup commits)
- Never force-push to `main` or `master`
