# skill-forge

[![Validate](https://github.com/your-org/skill-forge/actions/workflows/validate.yml/badge.svg)](https://github.com/your-org/skill-forge/actions/workflows/validate.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

A filesystem-based skill management system for LLMs.

Skills are directories. State is encoded in the directory name. Symlinks control which skills are visible to Claude, Gemini, and other LLM agents — no database, no background services, no dependencies beyond bash.

## Why

LLM agents load context from designated directories (`~/.claude/skills/`, `~/.gemini/skills/`). skill-forge gives you a disciplined workflow to manage what lands there: activate skills when they're needed, put them in review when they're being updated, deactivate them when they're not, and decommission them when they're retired — all with a single CLI.

The state lives in the filesystem. `ls $LLM_SKILLS_HOME/skills/` shows you everything. No config drift. No hidden state.

## Install

```bash
git clone https://github.com/your-org/skill-forge.git
cd skill-forge
bash scripts/install.sh
source ~/.bashrc  # or ~/.zshrc
```

## Quick Start

```bash
# List all skills and their states
agents ls

# Make a skill visible to LLMs
agents activate architect

# Put a skill under review (hidden from LLMs)
agents review engineer

# Detect and auto-fix invariant violations
agents audit

# Verify the environment
agents doctor
```

## How It Works

Every skill is a directory named `<name>.<state>`:

```
$LLM_SKILLS_HOME/skills/
  architect.active/          ← visible to LLMs (symlinks exist)
  engineer.active/           ← visible to LLMs
  tester.review/             ← hidden (no symlinks)
  old-skill.decommissioned/  ← retired, kept for audit trail
```

Transitioning between states is a rename. Visibility is controlled by symlinks in `~/.claude/skills/` and `~/.gemini/skills/`. The invariant is simple: `active` state means symlinks exist; any other state means they don't.

Run `agents audit` at any time to detect and repair violations.

See [docs/how-it-works.md](docs/how-it-works.md) for a full explanation.

## CLI Reference

| Command | Description |
|---|---|
| `agents ls` | List all skills with state and symlink status |
| `agents status` | Verify active↔symlinks invariant |
| `agents activate <name>` | Transition to active; create symlinks |
| `agents review <name>` | Transition to review; remove symlinks |
| `agents deactivate <name>` | Transition to deactivated; remove symlinks |
| `agents rm <name>` | Decommission (permanent rename, no data loss) |
| `agents audit` | Detect and auto-fix all violations |
| `agents doctor` | Self-check paths, permissions, and PATH |

See [docs/cli.md](docs/cli.md) for full documentation.

## Safe Testing

Test without touching your live `$LLM_SKILLS_HOME`:

```bash
LLM_SKILLS_HOME=/tmp/skills-test bash scripts/install.sh
LLM_SKILLS_HOME=/tmp/skills-test agents ls
```

## Skill Format

Each skill directory contains a `SKILL.md` with required frontmatter:

```yaml
---
name: architect
description: Apply systems architect expertise for HLD generation and design reviews.
disable-model-invocation: true
---
```

See [docs/skill-spec.md](docs/skill-spec.md) for the full specification.

## Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feat/my-feature`
3. Make changes, run `bash -n scripts/agents.sh` and `bash -n scripts/install.sh`
4. Test locally: `LLM_SKILLS_HOME=/tmp/skills-test bash scripts/install.sh`
5. Open a pull request — CI validates all SKILL.md files and runs smoke tests automatically

## License

[MIT](LICENSE)
