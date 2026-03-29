# GitHub PR Subflow

Handles creating, reviewing, merging, and closing GitHub pull requests using the `gh` CLI.
All write operations require explicit user approval before execution.

## Workflow

### 1. Identify Operation

```
PR operation:
  1. Create a new PR
  2. View an open PR
  3. Review a PR (approve / request changes / comment)
  4. Merge a PR
  5. Close a PR (without merging)
  6. List open PRs

Enter 1–6:
```

### 2. Gather Details per Operation

**Create PR:**
- Title
- Base branch (default: main)
- Body (ask or offer to generate from commit messages)
- Draft? (yes / no)
- Reviewers (optional, comma-separated GitHub usernames)

**Merge PR:**
- PR number or URL
- Merge strategy: merge commit / squash / rebase
- Delete branch after merge? (yes / no)

**Review:** PR number, review type, and comment body.

**Close:** PR number and reason.

### 3. Propose Commands

Present dry-run for approval. For merge operations include a warning if the PR has failing checks:
```
⚠ CI checks are failing or still running. Merge anyway?
```

```
Proposed actions:
─────────────────
1. gh pr create --title "..." --body "..." --base main
   [or other gh command]

Proceed? (yes / edit / cancel)
```

### 4. Execute on Approval

Run the command. Print output and the resulting PR URL on creation.
On failure: stop, show error, ask how to proceed.

## Guidelines

- Always check `gh auth status` before any `gh` command. If unauthenticated, stop and prompt: `Run: gh auth login`
- Check CI status before proposing a merge: `gh pr checks <number>`
- Respect branch protection rules — if a merge is likely to be rejected, warn before proposing the command.
- Never close a PR with unreviewed changes without explicit user confirmation.
