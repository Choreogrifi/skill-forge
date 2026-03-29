# Scripts

CLI and maintenance scripts for Skill Forge.

---

## Scripts reference

### `skillforge.sh`

The main CLI. Installed as `skillforge` in `~/.local/bin/` during setup.

```bash
skillforge help              # full command reference
skillforge ls                # list all skills and their states
skillforge activate <name>   # activate a skill (creates symlinks)
skillforge deactivate <name> # deactivate a skill (removes symlinks)
skillforge review <name>     # mark a skill as under review
skillforge rm <name>         # decommission a skill (permanent)
skillforge audit             # detect and auto-fix symlink violations
skillforge lint [file]       # check markdown quality
skillforge doctor            # check environment, tools, and PATH
skillforge config            # show current configuration
skillforge memory-help       # guide to memory files and token costs
skillforge version           # print installed version
```

---

### `install.sh`

Interactive installer. Run once to set up Skill Forge for the first time, or again to update an existing install.

```bash
bash scripts/install.sh
```

What it does:
1. Asks where to install (default: `~/.skillforge`)
2. Asks which LLMs to configure (Claude, Gemini)
3. Detects available tools (git, gh, glab, gcloud, terraform)
4. Creates `~/.skillforge/config.yaml` with your choices
5. Installs `skillforge` to `~/.local/bin/`
6. Creates skill symlinks for active skills
7. Adds `~/.local/bin/` to your shell's PATH if needed

Safe to re-run — it is idempotent.

---

### `check-skill-names.sh`

Validates that all skill directory names follow the naming convention.

```bash
bash scripts/check-skill-names.sh          # check all skills
bash scripts/check-skill-names.sh --staged # check only staged files (for pre-commit)
```

This script is also wired into `skillforge audit` automatically.

Exit code 0 = all names comply. Exit code 1 = violations found.

---

### `refactor.sh`

Utility script for bulk refactoring tasks (renaming, restructuring). Review its contents before running — it is a one-off maintenance tool, not a regular workflow.

---

### `hooks/`

Git hooks for this repository. Used during development of Skill Forge itself.

To install the hooks:
```bash
cp scripts/hooks/pre-commit .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit
```

The pre-commit hook runs `check-skill-names.sh --staged` before each commit to prevent naming violations from being committed.
