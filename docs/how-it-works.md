---
title: How It Works
---

# How It Works

## The Filesystem as State

skill-forge has no database, no config files, and no background services. The filesystem **is** the state.

Every skill is a directory. The directory name encodes both the skill's identity and its lifecycle state:

```
architect.active/
engineer.review/
tester.deactivated/
old-skill.decommissioned/
```

The format is always `<name>.<state>`. State is the suffix after the last dot. Because skill names use only lowercase letters, digits, and hyphens — never dots — splitting on the last dot is unambiguous.

## Four States

| State | Meaning | LLM visibility |
|---|---|---|
| `active` | Production-ready | Visible (symlinks exist) |
| `review` | Under evaluation | Hidden (no symlinks) |
| `deactivated` | Temporarily off | Hidden (no symlinks) |
| `decommissioned` | Permanently retired | Hidden (no symlinks) |

Transitioning between states is a rename (`mv`). No metadata to update. No database to sync.

## Symlinks as the Visibility Gate

LLM agents (Claude, Gemini) discover skills by scanning their designated directories:

```
~/.claude/skills/
~/.gemini/skills/
```

When a skill is **active**, a symlink is created in each of these directories pointing to the skill directory:

```
~/.claude/skills/architect  →  $LLM_SKILLS_HOME/skills/architect.active/
~/.gemini/skills/architect  →  $LLM_SKILLS_HOME/skills/architect.active/
```

When a skill is **not active**, those symlinks do not exist. The agent cannot see the skill.

This means visibility is controlled entirely at the filesystem level — no agent config, no allowlists, no restart required.

## The Invariant

There is one rule that must always hold:

> `state == active` ↔ symlinks exist in `~/.claude/skills/` and `~/.gemini/skills/`

The `agents audit` command detects and repairs violations automatically.

## The `LLM_SKILLS_HOME` Variable

All paths are derived from `LLM_SKILLS_HOME` (default: `~/.llm-assets`):

```bash
LLM_SKILLS_HOME="${LLM_SKILLS_HOME:-$HOME/.llm-assets}"
SKILLS_DIR="${LLM_SKILLS_HOME}/skills"
```

Override it to run against a test environment without touching live data:

```bash
LLM_SKILLS_HOME=/tmp/skills-test agents ls
```

## Why No Database?

- **Observability**: `ls $LLM_SKILLS_HOME/skills/` shows the complete system state instantly.
- **Durability**: No corruption risk — there's nothing to corrupt beyond a directory rename.
- **Portability**: The entire skill set is a directory tree. Copy it, version it, back it up with standard tools.
- **Debuggability**: `find`, `ls -la`, and `readlink` are sufficient to diagnose any issue.
