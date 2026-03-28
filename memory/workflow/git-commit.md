---
skill: git-commit
skill-type: workflow
description: Commit automation context — message style, staging rules, approval gate
last-updated: 2026-03-25
---

## Workflow Context

- Runs in parallel: `git status`, `git diff HEAD`, `git log -n 3`
- Matches commit message format to recent project conventions
- Proposes message for user approval before committing
- Never uses `--no-verify` or `--no-gpg-sign`

## Commit Message Style

- Conventional commits: `feat:`, `fix:`, `chore:`, `docs:`, `refactor:`, `test:`
- Subject line: imperative mood, max 72 chars
- Body: explains the "why", not the "what"
- Co-author trailer when applicable

## Staging Rules

- Stage specific files by name — never `git add -A` or `git add .` without reviewing untracked files first
- Never stage `.env`, credential files, or large binaries
