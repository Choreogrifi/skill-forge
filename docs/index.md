---
title: skill-forge
---

# skill-forge

A filesystem-based skill management system for LLMs.

Skills are directories. State is encoded in the directory name. Symlinks control which skills are visible to Claude, Gemini, and other LLM agents — no database, no background services.

## Install

```bash
git clone https://github.com/Choreogrifi/skill-forge.git
cd skill-forge
bash scripts/install.sh
```

## Quick Start

```bash
# List all skills and their states
agents ls

# Activate a skill (makes it visible to LLMs)
agents activate architect

# Check symlink health
agents status

# Run a full audit and auto-fix violations
agents audit

# Self-check the environment
agents doctor
```

## Learn More

- [Getting Started](getting-started.md) — prerequisites and first steps
- [How It Works](how-it-works.md) — the filesystem model explained
- [CLI Reference](cli.md) — all commands with examples
- [SKILL.md Specification](skill-spec.md) — skill format and naming rules
