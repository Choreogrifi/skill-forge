---
title: Getting Started
---

# Getting Started

## Prerequisites

- Bash 4.0 or later (`bash --version`) — macOS ships Bash 3, install via `brew install bash`
- Standard Unix tools: `find`, `ln`, `mv`, `cp`, `grep`, `sed`
- Git (for cloning)
- `~/.local/bin` writable (or a custom `$PATH` location)

## Install

### 1. Clone the repository

```bash
git clone https://github.com/Choreogrifi/skill-forge.git
cd skill-forge
```

### 2. Run the installer

```bash
bash scripts/install.sh
```

The installer will prompt you for:
- **Install directory** — where Skill Forge assets live (default: `~/.skillforge`)
- **LLM targets** — which LLMs you use: `claude`, `gemini`, or both
- **Email** — optional, for skill proposal notifications
- **System skills mode** — `Always-on` (skill detection and memory management embedded in `model.md`, active every session) or `Manual` (invoke `/skills-sme` or `/memory-wf` when needed). Default: `Manual`

It then:
- Detects available tools (`git`, `gh`, `gcloud`, `terraform`) and warns if any are missing
- Writes your configuration to `~/.skillforge/config.yaml`
- Copies the starter skills (never overwrites existing ones)
- Creates symlinks for all `active` skills in your LLM target directories
- Installs the `skillforge` CLI to `~/.local/bin/skillforge`
- Adds `~/.local/bin` to your PATH (if not already present)

### 3. Reload your shell

```bash
source ~/.zshrc   # or ~/.bashrc
```

### 4. Verify the installation

```bash
skillforge doctor
skillforge ls
```

## Testing New Skills

Use the test environment scripts to validate skills under development without touching your production install.

```bash
# Set up an isolated test environment
bash scripts/test-env-setup.sh

# Tear it down when done
bash scripts/test-env-teardown.sh
```

**What `test-env-setup.sh` does:**
- Creates `.tmp-skillforge/` in the repo root (`TMP_SKILLFORGE_DIR`) with a full skills directory structure.
- Copies SME skills from `skills/sme/` into the test environment.
- Creates symlinks at `~/.claude/skills/<name>` (or `~/.gemini/skills/<name>`) **only** for skills that have no existing production symlink. This makes test skills visible to your LLM immediately.
- Records every created symlink in `.tmp-skillforge/.test-manifest`.

**What `test-env-teardown.sh` does:**
- Removes only the symlinks listed in `.test-manifest` — production symlinks are never touched.
- Removes the `.tmp-skillforge/` directory entirely.

**Boundary rule — `SKILLFORGE_DIR` vs `TMP_SKILLFORGE_DIR`:**

| Variable | Purpose | Managed by |
|---|---|---|
| `SKILLFORGE_DIR` | Production install (`~/.skillforge` by default) | `install.sh` and `uninstall` only |
| `TMP_SKILLFORGE_DIR` | Test environment (`.tmp-skillforge/` in repo) | `test-env-setup.sh` and `test-env-teardown.sh` |

Never set `SKILLFORGE_DIR` manually for testing — doing so risks corrupting your production configuration.

## First Commands

```bash
# See all skills and their states
skillforge ls

# Activate a skill to make it visible to your LLM
skillforge activate engineer-sme

# Put a skill under review (invisible to LLMs while being updated)
skillforge review tester-sme

# Check for invariant violations and auto-fix them
skillforge audit

# Learn about memory files and token costs
skillforge memory-help
```

## Uninstall

```bash
skillforge uninstall
```

Walks you through removing symlinks, the binary, and optionally the skill data directory and PATH entries. Skill data is never deleted without a separate explicit confirmation — a reinstall after uninstall will find your skills intact.
