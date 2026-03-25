# skills.sh — Build & Deployment Execution Plan

You are a senior software engineer and DevOps agent responsible for building, validating, and deploying a production-ready repository and documentation site for **skills.sh**.

This is a **filesystem-based skill system for LLMs**.

Your execution must be:

- Deterministic
- Idempotent
- Verifiable at each stage
- Safe (no destructive operations outside project scope)

---

# 🧠 SYSTEM OVERVIEW

Core principles:

- Skills are directories
- State is encoded in directory names: `<name>.<state>`
- Valid states:
  - active
  - review
  - deactivated
  - decommissioned

- Symlinks control visibility
- Filesystem is the single source of truth
- No database, no background services

---

# 🎯 OBJECTIVES

You must:

1. Create a clean GitHub-ready repository
2. Implement a working CLI (`agents`)
3. Implement a safe install script (`install.sh`)
4. Include a minimal but functional skill set
5. Create a GitHub Pages documentation site
6. Validate all functionality locally
7. Provide deployment instructions

---

# ⚠️ GLOBAL GUARDRAILS

You MUST follow these rules:

- NEVER hardcode user-specific paths
- ALWAYS use:

  ```bash
  LLM_SKILLS_HOME="${LLM_SKILLS_HOME:-$HOME/.llm-assets}"
  ```

- NEVER overwrite existing user data without explicit checks
- ALL scripts must be idempotent
- FAIL FAST on errors (`set -euo pipefail`)
- DO NOT introduce external dependencies (Node, Python, etc.)
- USE ONLY bash + standard Unix tools

---

# 📁 STEP 1 — CREATE REPOSITORY STRUCTURE

Create the following structure:

```
skills.sh/
  skills/
    architect.active/
      SKILL.md
    engineer.active/
      SKILL.md
    tester.active/
      SKILL.md
    manage-skills.active/
      SKILL.md

  scripts/
    install.sh
    agents.sh

  docs/
    index.md
    getting-started.md
    how-it-works.md
    cli.md
    skill-spec.md

  README.md
  LICENSE
```

---

# ✅ VALIDATION CHECKPOINT 1

- All directories exist
- Each skill directory contains `SKILL.md`
- No empty required files

---

# ⚙️ STEP 2 — IMPLEMENT CLI (`agents.sh`)

## Requirements

- Must support:

```
agents ls
agents status
agents activate <name>
agents review <name>
agents deactivate <name>
agents rm <name>
agents audit
agents doctor
```

---

## Core Logic Rules

- Skills live in:

  ```
  $LLM_SKILLS_HOME/skills
  ```

- Extract name/state from directory:

  ```
  <name>.<state>
  ```

- Use:
  - `mv` for state transitions
  - `ln -s` for activation
  - `rm -f` for symlink removal

---

## Required Functions

Implement modular functions:

- `list_skills`
- `get_state`
- `set_state`
- `create_symlinks`
- `remove_symlinks`
- `reconcile_symlinks`
- `validate_structure`

---

## Symlink Targets

```
$HOME/.claude/skills/
$HOME/.gemini/skills/
```

---

## Invariant Enforcement

- IF state == active → symlinks MUST exist
- IF state != active → symlinks MUST NOT exist

---

# ✅ VALIDATION CHECKPOINT 2

Run:

```bash
agents ls
agents status
```

Expected:

- Skills listed with correct states
- No errors

---

# 🔧 STEP 3 — IMPLEMENT INSTALL SCRIPT

File: `scripts/install.sh`

---

## Requirements

- Must be idempotent
- Must:

1. Create directories:

```bash
$HOME/.llm-assets/skills
$HOME/.claude/skills
$HOME/.gemini/skills
$HOME/.local/bin
```

2. Copy starter skills if not already present

3. Install CLI:

```bash
cp scripts/agents.sh ~/.local/bin/agents
chmod +x ~/.local/bin/agents
```

4. Ensure PATH includes:

```bash
~/.local/bin
```

(Only append if missing)

---

## Safety Checks

- If directory exists → DO NOT overwrite
- If file exists → warn, do not replace silently

---

## Output

Must clearly print:

- Installed paths
- CLI location
- Next steps

---

# ✅ VALIDATION CHECKPOINT 3

After install:

```bash
agents ls
```

Must work without errors.

---

# 🧠 STEP 4 — CREATE MINIMAL SKILLS

Each `SKILL.md` must include:

```yaml
---
name: <name>
description: <clear description>
disable-model-invocation: true
---
```

---

## Guardrails

- `name` MUST match directory name
- No empty descriptions
- Keep files concise

---

# ✅ VALIDATION CHECKPOINT 4

- All SKILL.md files valid
- No missing fields

---

# 🌐 STEP 5 — DOCUMENTATION SITE

Use `/docs` for GitHub Pages.

---

## Required Content

### index.md

- Project description
- Install command
- Example usage

### getting-started.md

- Install steps
- First commands

### how-it-works.md

Explain:

- Directory-based state
- Symlink activation
- Filesystem model

### cli.md

Document all commands

### skill-spec.md

Define SKILL.md format

---

# ✅ VALIDATION CHECKPOINT 5

- All docs render as valid markdown
- No broken links

---

# 📦 STEP 6 — README

Must include:

1. What this is
2. Why it exists
3. Install command
4. Quickstart
5. Example usage
6. How it works (short)
7. Contributing
8. License

---

# ✅ VALIDATION CHECKPOINT 6

- README is complete
- Commands are copy-paste runnable

---

# 🚀 STEP 7 — DEPLOYMENT

## GitHub

1. Initialize repo:

```bash
git init
git add .
git commit -m "Initial commit"
```

2. Create GitHub repo
3. Push:

```bash
git remote add origin <repo-url>
git branch -M main
git push -u origin main
```

---

## GitHub Pages

1. Go to repo settings
2. Enable Pages
3. Set source: `/docs`
4. Save

---

# ✅ VALIDATION CHECKPOINT 7

- Site loads successfully
- Docs visible at published URL

---

# 🧪 FINAL VERIFICATION

Run full test:

```bash
./scripts/install.sh
agents ls
agents activate architect
agents review architect
agents doctor
```

Expected:

- No errors
- State transitions correct
- Symlinks correct

---

# 🧠 FAILURE HANDLING

If ANY step fails:

1. STOP execution
2. Output:
   - Exact failure
   - File involved
   - Suggested fix

3. DO NOT continue blindly

---

# 🏁 SUCCESS CRITERIA

Project is complete ONLY if:

- CLI works end-to-end
- Install script is safe and repeatable
- Skills are valid
- Docs are accessible
- GitHub Pages is live
- All validation checkpoints pass

---

# Post Deployment

Add the following:

- Add a CI pipeline (GitHub Actions) that enforces these rules automatically
- Or create a test harness for the CLI so every PR is validated

Execute all steps with precision.
Do not skip validation.
Do not assume success—verify it.
