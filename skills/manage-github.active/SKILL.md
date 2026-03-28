---
name: manage-github
skill-type: workflow
memory-file: workflow/manage-github.md
description: Handles all GitHub and local git operations for the current repository using the git and gh CLIs. Every action is presented for user confirmation before execution. Activated by manage-git; also invoke directly for GitHub-specific operations.
disable-model-invocation: true
---

# Manage GitHub

Executes git and GitHub operations against the current repository. Uses `git` for local operations and `gh` for GitHub platform operations. Every proposed action is presented as a dry-run summary — nothing executes without explicit user approval.

## Workflow

### 1. Receive Request

Accept the user's requested operation in plain language (e.g. "create a PR", "merge branch X into main", "show open issues").

### 2. Resolve Commands

Translate the request into specific `git` / `gh` commands. Read `references/github-operations.md` to look up the correct command syntax for the operation.

Present a dry-run summary:

```
Proposed actions:
─────────────────
1. git checkout -b feature/my-branch
2. git push origin feature/my-branch
3. gh pr create --title "..." --body "..." --base main

Proceed? (yes / edit / cancel)
```

- If the operation is **destructive** (force push, branch delete, reset, close PR/issue), prepend a warning:
  ```
  ⚠ This action is irreversible: <description>
  ```

### 3. Confirm

- `yes` → proceed to Step 4.
- `edit` → ask what to change, revise the proposed commands, return to this step.
- `cancel` → stop; nothing is executed.

### 4. Execute

Run each command in sequence. After each command:
- On success: print the output.
- On failure: stop immediately, show the error, and ask the user how to proceed.

After all commands complete, summarise:

```
Done.
─────
<command> → <outcome>
<command> → <outcome>
```

### 5. Next Request

Ask: `Anything else? (describe next operation or "done")`

Return to Step 1 on any new request. Exit on "done".

## Guidelines

- **Confirm before every execution** — no exceptions, including for read-only commands that output sensitive data.
- **One operation at a time** — do not batch unrelated operations into a single confirmation.
- **Check auth before platform ops** — if a `gh` command is needed and `gh auth status` fails, prompt the user to run `gh auth login` before continuing.
- **Respect branch protection** — if a push or merge is likely blocked by branch protection rules, warn the user before proposing the command.
- **Never force-push to main/master** — refuse and suggest an alternative if requested.

## References

- `references/github-operations.md` — full command reference for local git and GitHub platform operations; read during Step 2
