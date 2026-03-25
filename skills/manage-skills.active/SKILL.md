---
name: manage-skills
description: Manage the full lifecycle of custom skills — list, create, activate, review, deactivate, decommission, and audit. Invoke when you want to change a skill's state or audit the skill registry.
disable-model-invocation: true
---

# Manage Skills

Manages skills stored in `$LLM_SKILLS_HOME/skills/`. State is encoded in the directory name — no metadata field required. Use the `agents` CLI for all lifecycle operations.

## Paths

| Resource | Path |
|---|---|
| Skill source | `$LLM_SKILLS_HOME/skills/<name>.<state>/` |
| Claude symlinks | `$HOME/.claude/skills/<name>` → source (active only) |
| Gemini symlinks | `$HOME/.gemini/skills/<name>` → source (active only) |

## State Model

| State | Directory name | LLM visibility |
|---|---|---|
| **active** | `<name>.active` | Visible (symlinks exist) |
| **review** | `<name>.review` | Hidden (no symlinks) |
| **deactivated** | `<name>.deactivated` | Hidden (no symlinks) |
| **decommissioned** | `<name>.decommissioned` | Hidden (permanent) |

State is the suffix of the directory name after the last `.`. Symlinks are the sole visibility control.

## Invariant

- `state == active` → symlinks MUST exist in `~/.claude/skills/` and `~/.gemini/skills/`
- `state != active` → symlinks MUST NOT exist

Run `agents audit` to detect and auto-fix violations.

## CLI Operations

| Operation | Command |
|---|---|
| List all skills | `agents ls` |
| Check invariants | `agents status` |
| Activate | `agents activate <name>` |
| Put in review | `agents review <name>` |
| Deactivate | `agents deactivate <name>` |
| Decommission | `agents rm <name>` |
| Fix all violations | `agents audit` |
| Health check | `agents doctor` |

## SKILL.md Required Frontmatter

```yaml
---
name: <name>           # must match directory name prefix exactly
description: <text>    # non-empty
disable-model-invocation: true
---
```

## Guidelines

- Never delete a skill directory — use `agents rm` to decommission instead.
- Symlinks point to the skill directory itself, not to `SKILL.md`.
- Run `agents audit` after any manual filesystem changes.
- Test safely: `LLM_SKILLS_HOME=/tmp/skills-test agents ls`
