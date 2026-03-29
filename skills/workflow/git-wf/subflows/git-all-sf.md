# Git All Subflow

Runs the full add → commit → push sequence in one guided flow.
Each stage requires explicit confirmation before proceeding.

## Workflow

### 1. Show Working Tree Status

Run `git status` to display all modified, staged, and untracked files.

### 2. Stage Files

If nothing is staged:
- Show the list of modified tracked files.
- Ask: "Which files should I stage? (list paths, 'all modified tracked', or 'cancel')"
- Stage the specified files by name. Never use `git add .` or `git add -A`.

If files are already staged, confirm with the user before proceeding.

### 3. Commit (Diff-Driven)

Follow the full commit flow from `git-commit-sf`:
1. Run `git diff --cached` to read the staged diff.
2. Run `git log --oneline -5` for commit style reference.
3. Draft a commit message from the diff.
4. Present the message:
   ```
   Proposed commit message:
   ────────────────────────
   <subject>

   <body if needed>
   ────────────────────────
   Use this message? (yes / edit / cancel)
   ```
5. On `yes`: commit with the approved message.
6. On `edit`: re-draft and return to step 4.
7. On `cancel`: stop — nothing is committed.

### 4. Push

After a successful commit:
- Identify the current branch and its remote tracking branch.
- Propose: `git push origin <branch>`
- Ask: "Push to origin/<branch>? (yes / no)"
- On `yes`: push. Print the output.
- On `no`: inform the user the commit is saved locally.

## Guidelines

- **Never push without confirmation** — always ask, even after a successful commit.
- **Respect scope** — if the user wants only some files committed, stage only those and leave the rest for a second commit.
- **Never skip hooks** (`--no-verify`) unless the user explicitly requests it.
- **Force-push is never part of this flow** — if the push is rejected, show the error and suggest `git pull --rebase` before pushing again.
