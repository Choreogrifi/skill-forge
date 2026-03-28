---
name: manage-gitlab
skill-type: workflow
memory-file: workflow/manage-gitlab.md
description: Handles all GitLab and local git operations for the current repository using the git and glab CLIs. Every action is presented for user confirmation before execution. Activated by manage-git; also invoke directly for GitLab-specific operations.
disable-model-invocation: true
---

# Manage GitLab

Executes git and GitLab operations against the current repository. Uses `git` for local operations and `glab` for GitLab platform operations. Every proposed action is presented as a dry-run summary — nothing executes without explicit user approval.

## Workflow

### 1. Receive Request

Accept the user's requested operation in plain language (e.g. "create an MR", "trigger the pipeline", "list open issues").

### 2. Resolve Commands

Translate the request into specific `git` / `glab` commands. Read `references/gitlab-operations.md` to look up the correct command syntax for the operation.

Present a dry-run summary:

```
Proposed actions:
─────────────────
1. git checkout -b feature/my-branch
2. git push origin feature/my-branch
3. glab mr create --title "..." --description "..." --target-branch main

Proceed? (yes / edit / cancel)
```

- If the operation is **destructive** (force push, branch delete, reset, close MR/issue, cancel pipeline), prepend a warning:
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
- **Check auth before platform ops** — if a `glab` command is needed and `glab auth status` fails, prompt the user to run `glab auth login` before continuing.
- **Respect protected branches** — if a push or merge is likely blocked by branch protection, warn the user before proposing the command.
- **Never force-push to main/master** — refuse and suggest an alternative if requested.
- **Pipeline awareness** — when merging an MR, check if a pipeline is required to pass (`glab mr view`) and warn the user if it is still running or has failed.

## References

- `references/gitlab-operations.md` — full command reference for local git and GitLab platform operations; read during Step 2
