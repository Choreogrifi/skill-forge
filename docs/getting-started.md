---
title: Getting Started
---

# Getting Started

## Prerequisites

- Bash 4.0 or later (`bash --version`)
- Standard Unix tools: `find`, `ln`, `mv`, `cp`, `grep`, `sed`
- Git (for cloning)
- `~/.local/bin` writable (or a custom `$PATH` location)

## Install

### 1. Clone the repository

```bash
git clone https://github.com/your-org/skill-forge.git
cd skill-forge
```

### 2. Run the installer

```bash
bash scripts/install.sh
```

The installer:
- Creates `$LLM_SKILLS_HOME/skills/`, `~/.claude/skills/`, `~/.gemini/skills/`
- Copies the starter skills (never overwrites existing ones)
- Installs the `agents` CLI to `~/.local/bin/agents`
- Adds `~/.local/bin` to your PATH (if not already present)
- Creates symlinks for all `active` starter skills

### 3. Reload your shell

```bash
source ~/.bashrc   # or ~/.zshrc
```

### 4. Verify the installation

```bash
agents doctor
agents ls
```

## Safe Testing (Recommended Before Live Use)

Test against a temporary directory so your live `$LLM_SKILLS_HOME` is never touched:

```bash
LLM_SKILLS_HOME=/tmp/skills-test bash scripts/install.sh
LLM_SKILLS_HOME=/tmp/skills-test agents ls
```

## First Commands

```bash
# See all skills and their states
agents ls

# Activate a skill to make it visible to LLMs
agents activate engineer

# Put a skill under review (invisible to LLMs)
agents review tester

# Check for invariant violations
agents audit
```

## Uninstall

```bash
rm ~/.local/bin/agents
```

Skill data in `$LLM_SKILLS_HOME/skills/` is preserved. Remove it manually if desired.
