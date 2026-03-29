---
title: skill-forge
---

# skill-forge

A filesystem-based skill management system for LLMs.

Skills are directories. State is encoded in directory location. Symlinks control which skills are visible to Claude, Gemini, and other LLM assistants — no database, no background services.

## Install

**Homebrew (macOS / Linux)**

```bash
brew tap choreogrifi/skill-forge
brew install skill-forge
```

**curl one-liner**

```bash
curl -fsSL https://raw.githubusercontent.com/Choreogrifi/skill-forge/main/scripts/install.sh | bash
```

**From source**

```bash
git clone https://github.com/Choreogrifi/skill-forge.git
cd skill-forge
bash scripts/install.sh
```

## Quick Start

```bash
# List all skills and their states
skillforge ls

# Activate a skill (makes it visible to LLMs)
skillforge activate architect-sme

# Check symlink health
skillforge status

# Run a full audit and auto-fix violations
skillforge audit

# Self-check the environment
skillforge doctor
```

## Learn More

- [Getting Started](getting-started.md) — prerequisites and first steps
- [How It Works](how-it-works.md) — the filesystem model, skill types, memory system, and self-discovery
- [Skill Catalog](skill-catalog.md) — all built-in SME and workflow skills
- [CLI Reference](cli.md) — all commands with examples
- [SKILL.md Specification](skill-spec.md) — skill format and naming rules
