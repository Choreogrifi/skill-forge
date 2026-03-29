# Git Branch Subflow

Handles branch creation, renaming, deletion, and remote tracking.
All operations require explicit user approval before execution.

## Workflow

### 1. Identify Operation

Ask the user what they want to do:

```
Branch operation:
  1. Create a new branch
  2. Rename a branch
  3. Delete a branch (local)
  4. Delete a remote branch
  5. Set or change remote tracking

Enter 1–5:
```

### 2. Gather Details per Operation

**Create:**
- Branch name (must follow convention: `<type>/<ticket>-<description>`)
- Base branch (default: current branch)
- Push to remote and set tracking? (yes / no)

**Rename:**
- Current name → new name
- Update remote? (yes / no)

**Delete (local):**
- Branch name
- Warn if branch has unmerged commits

**Delete (remote):**
- Remote branch name
- Warn: this is irreversible

**Remote tracking:**
- Local branch → remote branch

### 3. Propose Commands

Present a dry-run summary. For destructive operations prepend:
```
⚠ This action is irreversible: <description>
```

```
Proposed actions:
─────────────────
1. <command>
2. <command>

Proceed? (yes / edit / cancel)
```

### 4. Execute on Approval

Run each command in sequence. Print output after each command.
On failure: stop immediately, show error, ask how to proceed.

## Guidelines

- **Never delete main or master** — refuse and explain.
- **Branch naming convention:** `<type>/<ticket>-<description>` where type is `feat`, `fix`, `chore`, `docs`, `refactor`.
- Warn when deleting a branch with commits not present on the default branch.
- After renaming a remote branch, remind the user to update any open PRs/MRs.
