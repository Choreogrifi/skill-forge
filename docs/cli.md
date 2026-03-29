---
title: CLI Reference
---

# CLI Reference

## Environment

| Variable | Default | Description |
|---|---|---|
| `SKILLFORGE_DIR` | `~/.skillforge` | Skill root directory (read from `~/.skillforge/config.yaml`) |

Override for safe testing:
```bash
SKILLFORGE_DIR=/tmp/sf-test skillforge <command>
```

---

## `skillforge ls`

List all skills with their current state and symlink status.

```bash
skillforge ls
```

**Output columns:**

| Column | Values |
|---|---|
| SKILL | Skill name |
| STATE | `active` / `review` / `deactivated` / `decommissioned` |
| SYMLINKS | `ok` / `MISSING` / `STALE` / `-` |

---

## `skillforge status`

Verify the active↔symlinks invariant for every skill. Non-zero exit if violations exist.

```bash
skillforge status
```

---

## `skillforge activate <name>`

Transition a skill to `active` and create symlinks in all configured LLM target directories.

```bash
skillforge activate architect-sme
```

- Idempotent: no-ops if already active.
- Blocked if skill is `decommissioned`.

---

## `skillforge review <name>`

Transition a skill to `review` and remove its symlinks.

```bash
skillforge review engineer-sme
```

---

## `skillforge deactivate <name>`

Transition a skill to `deactivated` and remove its symlinks.

```bash
skillforge deactivate tester-sme
```

---

## `skillforge rm <name>`

Decommission a skill permanently. Requires interactive confirmation.

```bash
skillforge rm old-skill
```

- Prompts: `Decommission "old-skill"? This cannot be undone. [yes/N]:`
- Moves directory to `skills/decommissioned/{sme,workflow}/<name>/`.
- Removes symlinks.
- **No data is deleted.** The directory is preserved as an audit trail.

---

## `skillforge audit`

Detect and auto-fix all invariant violations. Safe to run at any time.

```bash
skillforge audit
```

**Checks performed:**

1. **Symlink invariant**: Active skills missing symlinks → creates them. Non-active skills with stale symlinks → removes them.
2. **Orphan symlinks**: Symlinks in LLM target directories with no matching skill directory → flagged.
3. **SKILL.md frontmatter**: Validates `name` (matches directory), `metadata` block, `skill-type`, `version`, and `disable-model-invocation: true`.

---

## `skillforge doctor`

Self-check the environment for configuration issues.

```bash
skillforge doctor
```

**Checks:**

- Config file (`~/.skillforge/config.yaml`) exists
- Install directory exists
- Skills directory exists and is writable
- LLM target directories exist
- `skillforge` binary is on PATH
- Tool availability (`git`, `gh`, `glab`, `gcloud`, `terraform`)
- Bash version ≥ 4.0

---

## `skillforge memory-help`

Print a guide to memory files, loading rules, and token cost implications.

```bash
skillforge memory-help
```

---

## `skillforge config`

Show or update the current configuration.

```bash
skillforge config                      # show config.yaml
skillforge config set user.email me@example.com  # update a value
```

---

## `skillforge version`

Print the installed version.

```bash
skillforge version
```

---

## Git Commands

_Available since skillforge 2.0.0_

`skillforge git` wraps standard git operations with two safety gates:

1. **Skill naming check** — before `commit`, if any staged files are under `skills/`, all staged skill directory names are validated against the naming standard (`<name>-(sme|wf)`). The commit is blocked if violations are found.
2. **Force-push protection** — before a force-push to `main` or `master`, explicit confirmation is required.

All other subcommands are passed directly to `git`, so the full git command set is available.

### `skillforge git status`

```bash
skillforge git status
```

### `skillforge git log`

```bash
skillforge git log --oneline -10
```

### `skillforge git diff`

```bash
skillforge git diff           # unstaged changes
skillforge git diff --staged  # staged changes
```

### `skillforge git add`

```bash
skillforge git add skills/sme/my-skill-sme/SKILL.md
```

### `skillforge git commit`

Diff-driven commit flow — always shows the staged diff before asking for a message:

1. Fails with a hint if nothing is staged.
2. Runs the skill naming gate if any staged files are under `skills/`.
3. Prints `git diff --cached --stat` and the full diff.
4. Prints the last 5 commits for style reference.
5. Prompts: `Enter commit message (review the diff above):`
6. Confirms the message before committing.

```bash
skillforge git add scripts/skillforge.sh
skillforge git commit
# → shows diff, prompts for message, confirms, then commits
```

### `skillforge git all`

Stages all modified tracked files, runs the diff-driven commit flow, then pushes — in a single guided sequence.

1. Shows `git status`.
2. If nothing staged, lists modified tracked files and asks for confirmation to stage them.
3. Runs `git diff --cached` and prompts for a commit message (same as `skillforge git commit`).
4. Confirms the commit.
5. Asks to push to `origin/<current-branch>`.

```bash
skillforge git all
```

---

### `skillforge git push`

Passes through to `git push`. Blocks unconfirmed force-push to `main` or `master`.

```bash
skillforge git push origin feat/my-branch
skillforge git push --force origin feat/my-branch   # requires confirmation if target is main/master
```

### `skillforge git pull`

```bash
skillforge git pull
```

### `skillforge git branch`

```bash
skillforge git branch                          # list branches
skillforge git branch feat/my-skill           # create branch
skillforge git branch -d feat/merged-branch   # delete branch
```

### `skillforge git checkout`

```bash
skillforge git checkout feat/my-branch
skillforge git checkout -b feat/new-branch
```

### `skillforge git clone`

```bash
skillforge git clone https://github.com/org/repo.git
```

### `skillforge git tag`

```bash
skillforge git tag v1.0.0
skillforge git tag -l
```

### `skillforge git pr`

Create a GitHub pull request. Requires `gh` CLI and `gh auth login`.

```bash
skillforge git pr --title "feat(skills): add my-skill-sme" --body "Adds new skill."
skillforge git pr                      # interactive mode
```

### `skillforge git mr`

Create a GitLab merge request. Requires `glab` CLI and `glab auth login`.

```bash
skillforge git mr --title "feat(skills): add my-skill-sme" --description "Adds new skill."
skillforge git mr                      # interactive mode
```

### `skillforge git repo-create`

Interactively creates a new GitHub or GitLab repository and wires up the local remote.

1. Detects provider from `origin` remote URL, or asks.
2. Prompts for name, visibility (private default), and optional description.
3. Confirms before creating.
4. Creates via `gh repo create` (GitHub) or `glab repo create` (GitLab).
5. Sets or updates `origin` remote to the new URL.
6. Offers to push the current branch.

```bash
skillforge git repo-create
```

Requires `gh` for GitHub or `glab` for GitLab, and an active auth session.

---

### `skillforge git repo-rename`

Renames the repository on the platform and updates the local `origin` remote URL in one step.

1. Reads `origin` remote to detect provider, owner, and current name.
2. Prompts for the new name.
3. Derives the new remote URL (preserving SSH or HTTPS protocol).
4. Confirms before proceeding.
5. Renames via `gh repo rename` (GitHub) or `glab api` PATCH (GitLab).
6. Runs `git remote set-url origin <new-url>` and verifies with `git remote -v`.

```bash
skillforge git repo-rename
```

---

### Pass-through

Any git subcommand not listed above is passed directly to `git`:

```bash
skillforge git stash
skillforge git rebase -i HEAD~3
skillforge git cherry-pick abc1234
```

---

## `skillforge uninstall`

Interactively removes Skill Forge from the system. Requires typing `uninstall` to confirm.

```bash
skillforge uninstall
```

**Steps performed:**

1. **Symlinks** — removes all skill symlinks from `~/.claude/skills/` and `~/.gemini/skills/`.
2. **Binary** — removes `~/.local/bin/skillforge`.
3. **Skill data** (optional, second confirmation) — removes `$SKILLFORGE_DIR` including all skills, memory files, and `config.yaml`.
4. **PATH entries** (optional) — removes the `export PATH` line added to `~/.bashrc` / `~/.zshrc` by the installer.

Skill data is never deleted unless you explicitly answer `yes` to the separate confirmation in step 3. This means an uninstall followed by a reinstall preserves all your skills.

---

## `skillforge lint [file]`

Check markdown quality of all SKILL.md files, or a specific file if provided.

```bash
skillforge lint                        # check all skills
skillforge lint skills/sme/git-sme/SKILL.md  # check one file
```

Uses `markdownlint` when available. Falls back to basic checks (frontmatter presence, trailing whitespace, H1 heading) if not installed.

---

## `skillforge help`

Print usage information.

```bash
skillforge help
skillforge --help
skillforge -h
```
