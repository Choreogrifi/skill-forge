---
name: git-commit
skill-type: workflow
memory-file: workflow/git-commit.md
description: Automate git commit creation — summarises workspace changes, proposes a commit message for user approval, then commits. Invoke when ready to commit staged or unstaged changes.
disable-model-invocation: true
---

# Git Commit Automation

## Workflow

### 1. Gather Information
Run in parallel:
- `git status` — untracked, modified, and staged files
- `git diff HEAD` — all changes in tracked files
- `git log -n 3` — recent commits to match style/format

### 2. Draft the Commit Message
- Focus on the "why" and "what" of the changes.
- Match format to existing project conventions (from recent commits).
- Note any untracked files you plan to stage.

### 3. Propose to the User
Present the drafted message and wait for explicit approval. Do not commit until confirmed.

### 4. Execute the Commit
Upon approval:
- Stage files by name (never `git add .` or `git add -A` — avoid accidentally staging secrets or large binaries).
- Commit with the approved message using a heredoc to preserve formatting.
- Verify with `git status`.

## Guidelines
- **Never push** unless explicitly instructed.
- **Respect scope** — if the user specifies partial commits, stage only those files.
- **Never skip hooks** (`--no-verify`) unless the user explicitly requests it.