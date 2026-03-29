# Git Conflict Subflow

Guides the user through resolving merge or rebase conflicts.
Never modifies files without showing the conflict and proposing a resolution.

## Workflow

### 1. Detect Conflicts

Run `git status` to identify conflicted files. Present them:

```
Conflicted files:
  <path> — <conflict type: merge / rebase / cherry-pick>
  <path>
```

If no conflicts are found, inform the user and exit.

### 2. For Each Conflicted File

Read the file and extract the conflict markers (`<<<<<<<`, `=======`, `>>>>>>>`).

Present to the user:

```
File: <path>
──────────────────────────────────────
OURS (current branch):
  <content between <<<<<<< and =======)

THEIRS (incoming change):
  <content between ======= and >>>>>>>)

Context (lines around the conflict):
  <surrounding lines>
──────────────────────────────────────
Resolution options:
  1. Keep ours
  2. Keep theirs
  3. Keep both (ours then theirs)
  4. Manually specify — describe what to keep

Enter 1–4:
```

### 3. Apply Resolution

On selection 1–3, propose the resolved content and confirm before writing:

```
Resolved content:
  <proposed content>

Apply this resolution to <path>? (yes / edit / cancel)
```

On selection 4, ask the user to describe the desired resolution, then propose it.

### 4. Mark Resolved

After writing: run `git add <path>` to mark the file as resolved.
Repeat for each conflicted file.

### 5. Complete the Operation

Once all conflicts are resolved:

```
All conflicts resolved. Next step:
  - Completing a merge  → run: git merge --continue
  - Completing a rebase → run: git rebase --continue
  - Completing a cherry-pick → run: git cherry-pick --continue

Proceed with the continue command? (yes / abort / cancel)
```

On `abort`: run the appropriate `--abort` command and confirm.

## Guidelines

- Never use `git checkout --ours` or `git checkout --theirs` without showing the user the content first.
- If a conflict is in a binary file, warn the user that automatic resolution is not possible and suggest a manual approach.
- Do not `git add` any file until its resolution has been explicitly approved.
