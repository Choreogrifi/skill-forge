---
title: CLI Reference
---

# CLI Reference

## Environment

| Variable | Default | Description |
|---|---|---|
| `LLM_SKILLS_HOME` | `$HOME/.llm-assets` | Skill root directory |

Override for safe testing:
```bash
LLM_SKILLS_HOME=/tmp/skills-test agents <command>
```

---

## `agents ls`

List all skills with their current state and symlink status.

```bash
agents ls
```

**Output columns:**

| Column | Values |
|---|---|
| SKILL | Skill name |
| STATE | `active` / `review` / `deactivated` / `decommissioned` |
| SYMLINKS | `ok` (active, symlinks valid) / `MISSING` (active, symlinks absent) / `STALE` (non-active, symlinks present) / `-` (non-active, no symlinks) |

---

## `agents status`

Verify the active↔symlinks invariant for every skill. Non-zero exit if violations exist.

```bash
agents status
```

---

## `agents activate <name>`

Transition a skill to `active` and create symlinks in `~/.claude/skills/` and `~/.gemini/skills/`.

```bash
agents activate architect
```

- Idempotent: no-ops if already active.
- Blocked if skill is `decommissioned`.

---

## `agents review <name>`

Transition a skill to `review` and remove its symlinks.

```bash
agents review engineer
```

- Idempotent: no-ops if already in review.
- The skill directory is renamed to `<name>.review`.

---

## `agents deactivate <name>`

Transition a skill to `deactivated` and remove its symlinks.

```bash
agents deactivate tester
```

- Idempotent: no-ops if already deactivated.
- The skill directory is renamed to `<name>.deactivated`.

---

## `agents rm <name>`

Decommission a skill permanently. Requires interactive confirmation.

```bash
agents rm old-skill
```

- Prompts: `Proceed with decommissioning "old-skill"? [yes/N]:`
- Renames the directory to `<name>.decommissioned`.
- Removes symlinks.
- **No data is deleted.** The directory is preserved as an audit trail.
- Cannot be reversed — create a new skill if the capability is needed again.

---

## `agents audit`

Detect and auto-fix all invariant violations. Safe to run at any time.

```bash
agents audit
```

**Checks performed:**

1. **Symlink invariant**: Active skills missing symlinks → creates them. Non-active skills with stale symlinks → removes them.
2. **Orphan symlinks**: Symlinks in `~/.claude/skills/` or `~/.gemini/skills/` with no matching skill directory → flagged.
3. **Global symlinks** (pointing to `~/.agents/skills/`): Stale targets flagged for manual removal; never auto-removed.
4. **SKILL.md frontmatter**: Validates `name`, `description`, and `disable-model-invocation: true` for each skill.

Symlink issues are auto-fixed. Frontmatter issues are flagged for manual review.

---

## `agents doctor`

Self-check the environment for configuration issues.

```bash
agents doctor
```

**Checks:**

- `LLM_SKILLS_HOME` exists
- Skills directory exists
- `~/.claude/skills/` and `~/.gemini/skills/` exist
- Skills directory is writable
- `agents` binary is on PATH
- Bash version ≥ 4.0

---

## `agents help`

Print usage information.

```bash
agents help
agents --help
agents -h
```
