# Skill-Forge Workspace — macOS Handover

**Date:** 2026-03-25
**Origin:** WSL2 / Ubuntu (`/home/leond/.llm-assets`)
**Destination:** macOS (home directory TBD)
**Purpose:** Transfer skill-forge workspace and continue development on macOS.

---

## What This Repository Is

This is the **skill-forge workspace** — a portable, file-based system that augments Claude Code
with a custom persona, structured memory, and a library of reusable skills.

| Component | Path | Purpose |
|---|---|---|
| Persona / model | `model.md` | Loaded as `~/.claude/CLAUDE.md` via symlink — governs all Claude Code sessions |
| Skills | `skills/` | Custom skill definitions, invoked via `~/.claude/skills/` symlinks |
| Memory | `memory/` | Persistent context loaded per skill activation |
| Templates | `skills/manage-skills.active/templates/` | Scaffolds for new skill creation |
| Deferred skill plans | `memory/deferred-skills/` | Skills proposed but not yet created |

Skills are governed by directory name suffix:
- `.active` — visible to Claude Code (symlinked)
- `.review` / `.deactivated` / `.decommissioned` — hidden, never invoke

---

## Prerequisites (macOS)

| Tool | Required | Notes |
|---|---|---|
| Claude Code CLI | Yes | Must be installed and authenticated |
| git | Yes | For ongoing version control |
| Gemini CLI | Optional | Symlinks created for it too; skip if not used |

---

## One-Time Setup on macOS

### 1. Place the repository

Clone or copy this repo to `~/.llm-assets`:

```bash
git clone <repo-url> ~/.llm-assets
# or
cp -r /path/to/backup ~/.llm-assets
```

### 2. Create required directories

```bash
mkdir -p ~/.claude/skills
mkdir -p ~/.gemini/skills
```

### 3. Link the persona

```bash
ln -sf ~/.llm-assets/model.md ~/.claude/CLAUDE.md
```

> If `~/.claude/CLAUDE.md` already exists and is not a symlink, back it up first.

### 4. Bootstrap skill symlinks

Run this block to symlink all 22 active skills into both Claude and Gemini:

```bash
SKILLS=(
  add-document
  architect
  devops
  document-writer
  documenter
  engineer
  gcp-project-discoverer
  git-commit
  manage-git
  manage-github
  manage-gitlab
  manage-skills
  memory-manager
  mermaid-drawer
  review-document
  security
  skill-detector
  terraform-creator
  terraform-discoverer
  tester
  update-document
  write-readme
)

for skill in "${SKILLS[@]}"; do
  ln -sf ~/.llm-assets/skills/${skill}.active ~/.claude/skills/${skill}
  ln -sf ~/.llm-assets/skills/${skill}.active ~/.gemini/skills/${skill}
done
```

### 5. Create machine-specific settings

Create `~/.llm-assets/.claude/settings.local.json` with the permissions block for your macOS
username. Template (replace `<your-username>` with the result of `whoami`):

```json
{
  "permissions": {
    "allow": [
      "Bash(ln -s /Users/<your-username>/.llm-assets/skills/find-skills /Users/<your-username>/.claude/skills/find-skills)",
      "Bash(ln -s /Users/<your-username>/.llm-assets/skills/find-skills /Users/<your-username>/.gemini/skills/find-skills)"
    ]
  }
}
```

Add any additional `ln -s` permissions you need for global skills under `~/.agents/skills/`.

This file is gitignored — it must be created fresh on each host.

### 6. Verify

```bash
# Persona symlink resolves correctly
cat ~/.claude/CLAUDE.md | head -3

# Skills are visible
ls ~/.claude/skills/ | wc -l   # expect 22

# Symlinks point to canonical source (not to ~/.claude/skills/)
ls -la ~/.claude/skills/architect
# should show: architect -> /Users/<you>/.llm-assets/skills/architect.active
```

---

## Hardcoded Path Audit

The following files contain **absolute Linux paths** (`/home/leond/`) that must be updated
after transfer. The rest of the workspace uses `~` notation and is portable as-is.

| File | What to update |
|---|---|
| `skills/manage-skills.active/SKILL.md` | All occurrences of `/home/leond/` → `/Users/<your-username>/` |

Quick update command (after cloning, replace `<you>` with your macOS username):

```bash
sed -i '' 's|/home/leond/|/Users/<you>/|g' \
  ~/.llm-assets/skills/manage-skills.active/SKILL.md
```

Verify no remaining Linux paths:

```bash
grep -r '/home/leond' ~/.llm-assets/
# expect: no output
```

---

## Active Skills Inventory (22)

| Skill | Type | Purpose |
|---|---|---|
| `architect` | sme-persona | GCP / Hexagonal Architecture design decisions |
| `devops` | sme-persona | GCP infrastructure, CI/CD, IaC standards |
| `engineer` | sme-persona | Python / TypeScript engineering standards |
| `security` | sme-persona | Security review, threat modelling |
| `tester` | sme-persona | TDD, pytest, Jest/Vitest patterns |
| `documenter` | sme-persona | Documentation standards |
| `document-writer` | workflow | Writes structured documents from brief |
| `review-document` | workflow | Reviews documents against standards |
| `update-document` | workflow | Updates existing documents |
| `add-document` | workflow | Adds new document to a project |
| `write-readme` | workflow | Generates README files |
| `git-commit` | workflow | Conventional commit workflow |
| `manage-git` | workflow | Branch, merge, rebase operations |
| `manage-github` | workflow | GitHub PR, issue, release operations |
| `manage-gitlab` | workflow | GitLab MR, pipeline operations |
| `gcp-project-discoverer` | workflow | Discovers and audits GCP project resources |
| `terraform-creator` | workflow | Scaffolds Terraform modules |
| `terraform-discoverer` | workflow | Discovers existing infra for Terraform import |
| `mermaid-drawer` | workflow | Generates Mermaid diagrams |
| `manage-skills` | system | Full skill lifecycle management (list, create, activate, audit) |
| `memory-manager` | system | Skill memory CRUD and audit |
| `skill-detector` | system | Detects coverage gaps and proposes new skills |

---

## Memory Structure

```
memory/
├── shared/
│   ├── identity.md              # Who the user is — loaded once per session
│   ├── workspace-conventions.md # GCP naming, tool versions, repo standards
│   └── symlink-registry.md      # Known symlinks — read before any directory scan
├── sme/
│   ├── architect.md
│   ├── devops.md
│   ├── documenter.md
│   ├── engineer.md
│   ├── security.md
│   └── tester.md
├── workflow/
│   ├── add-document.md
│   ├── document-writer.md
│   ├── gcp-project-discoverer.md
│   ├── git-commit.md
│   ├── manage-git.md
│   ├── manage-github.md
│   ├── manage-gitlab.md
│   ├── mermaid-drawer.md
│   ├── review-document.md
│   ├── terraform-creator.md
│   ├── terraform-discoverer.md
│   ├── update-document.md
│   └── write-readme.md
├── system/
│   ├── manage-skills.md
│   ├── memory-manager.md
│   └── skill-detector.md
└── deferred-skills/             # Proposed skills not yet created
```

Memory loading order on skill activation:
1. `shared/identity.md` — once per session
2. `<type>/<skill-name>.md` — per invocation

---

## Development Context

- This workspace is the active development environment for **skill-forge**.
- All future skill creation, modification, and lifecycle management happens here.
- Use `manage-skills` (via `/manage-skills` in Claude Code) to create or modify skills.
- Symlink registry (`memory/shared/symlink-registry.md`) must be kept up to date when
  new symlinks are added.

---

## Symlink Registry Summary

| Symlink | Canonical Source |
|---|---|
| `~/.claude/CLAUDE.md` | `~/.llm-assets/model.md` |
| `~/.claude/skills/<name>` | `~/.llm-assets/skills/<name>.active/` |
| `~/.gemini/skills/<name>` | `~/.llm-assets/skills/<name>.active/` |

**Rule:** Never read from `~/.claude/skills/` — always use `~/.llm-assets/skills/`.

---

## Post-Setup Smoke Test

1. Open Claude Code in any directory.
2. Run `/manage-skills` — expect the operations menu.
3. Select Op 1 (List skills) — expect 22 active skills.
4. Run `/architect` — expect a persona greeting or prompt for input.
5. If any skill errors, run Op 7 (Audit) to check for broken symlinks or missing memory files.
