# GitLab MR Subflow

Handles creating, reviewing, merging, and closing GitLab Merge Requests using the `glab` CLI.
All write operations require explicit user approval before execution.

## Workflow

### 1. Identify Operation

```
MR operation:
  1. Create a new MR
  2. View an open MR
  3. Approve an MR
  4. Merge an MR
  5. Close an MR (without merging)
  6. List open MRs

Enter 1–6:
```

### 2. Gather Details per Operation

**Create MR:**
- Title
- Target branch (default: main)
- Description (ask or offer to generate from commit messages)
- Draft? (yes / no — creates a "Draft:" MR)
- Reviewers (optional, comma-separated GitLab usernames)
- Remove source branch after merge? (yes / no)

**Merge MR:**
- MR IID (the `!123` number) or URL
- Squash commits? (yes / no)

**Close:** MR IID and reason.

### 3. Check Pipeline Before Merge

Before proposing a merge command, run:
```
glab mr view <iid> --output json
```
Extract pipeline status. If failing or still running, warn:
```
⚠ Pipeline is <failing / running>. The MR may be blocked by required checks.
```

### 4. Propose Commands

```
Proposed actions:
─────────────────
1. glab mr create --title "..." --description "..." --target-branch main
   [or other glab command]

Proceed? (yes / edit / cancel)
```

### 5. Execute on Approval

Run the command. Print output and the resulting MR URL on creation.
On failure: stop, show error, ask how to proceed.

## Guidelines

- Always check `glab auth status` before any `glab` command. If unauthenticated, stop and prompt: `Run: glab auth login`
- Always check pipeline status before proposing a merge.
- For Draft MRs, remind the user to remove the Draft status before merging: `glab mr update <iid> --ready`
- Respect protected branch rules — warn if a direct push or merge will be blocked.
