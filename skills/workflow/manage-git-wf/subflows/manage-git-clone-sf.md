# Git Clone Subflow

Handles cloning a repository — including sparse checkout and submodule initialisation.
Requires explicit user approval before executing any command.

## Workflow

### 1. Gather Clone Details

Ask the user:

```
Repository URL to clone:
Target directory (default: infer from repo name):
Clone type:
  1. Full clone (default)
  2. Sparse checkout — specify paths to include
  3. Shallow clone — specify depth (e.g. --depth 1)

Enter 1–3:
```

For sparse checkout, ask: `Which paths should be included? (space-separated, e.g. src/ docs/)`

### 2. Propose Commands

Present the full command sequence for approval:

```
Proposed actions:
─────────────────
1. git clone <url> <target-dir>
   [+ sparse/shallow flags if selected]
2. [if submodules detected] git submodule update --init --recursive

Proceed? (yes / edit / cancel)
```

Warn if the target directory already exists.

### 3. Execute on Approval

Run each command in sequence. After each:
- On success: print the output.
- On failure: stop, show the error, ask how to proceed.

### 4. Post-Clone Check

After successful clone:
- Run `git log --oneline -5` to confirm history was fetched.
- If submodules exist (`git submodule status`), offer to initialise them.

## Guidelines

- Never clone into a directory that already has a `.git` folder without explicit confirmation.
- For shallow clones, remind the user that history is incomplete and `git log --all` may be limited.
- For sparse checkouts, confirm the included paths with the user before proceeding.
