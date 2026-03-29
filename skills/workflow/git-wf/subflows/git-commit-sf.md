# Git Commit Subflow

Produces a commit message derived from the staged diff, presents it for user approval,
then commits. Never commits without explicit user confirmation.

## Workflow

### 1. Check Staged Changes

Run `git diff --cached --stat`.

If nothing is staged:
- Run `git status` to show modified and untracked files.
- Ask: "No files are staged. Which files should I stage? (list paths or 'all tracked')"
- Stage the specified files by name. Never use `git add .` or `git add -A` — always name files explicitly to avoid accidentally staging secrets or large binaries.
- Re-run `git diff --cached --stat` to confirm what is staged.

### 2. Read the Diff

Run `git diff --cached` to read the full staged diff.

Also run `git log --oneline -5` to understand the project's commit message style and conventions.

### 3. Draft the Commit Message

Derive the commit message directly from the diff output:

- **Subject line**: ≤72 characters. Summarises *what* changed and *why* — not just which files.
- **Body** (optional): wrap at 72 characters. Include only if the subject alone is insufficient.
- Match the style of recent commits from `git log`. If the project uses Conventional Commits, apply the correct prefix (`feat:`, `fix:`, `docs:`, `chore:`, `refactor:`, etc.).

Present to the user:

```
Proposed commit message:
────────────────────────
<subject line>

<body if needed>
────────────────────────
Use this message? (yes / edit / cancel)
```

### 4. Execute

On `yes`:
- Commit using a heredoc to preserve message formatting:
  ```bash
  git commit -m "$(cat <<'EOF'
  <subject>

  <body>
  EOF
  )"
  ```
- Run `git status` to confirm the working tree is clean.

On `edit`:
- Ask what to change. Re-draft and return to Step 3.

On `cancel`:
- Stop. Nothing is committed.

## Guidelines

- **Message must come from the diff** — never produce generic boilerplate. Read the actual changes.
- **Never push** unless explicitly instructed after the commit.
- **Never skip hooks** (`--no-verify`) unless the user explicitly asks.
- **Respect scope** — if the user wants a partial commit, ask which files to stage before reading the diff.
