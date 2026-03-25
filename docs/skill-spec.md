---
title: SKILL.md Specification
---

# SKILL.md Specification

## Directory Naming

Every skill is a directory under `$LLM_SKILLS_HOME/skills/`. The directory name encodes the skill's identity and lifecycle state:

```
<name>.<state>
```

**Name rules:**
- Lowercase letters, digits, and hyphens only
- Must start with a letter
- Pattern: `^[a-z][a-z0-9-]+$`
- Examples: `architect`, `manage-skills`, `gcp-project-discoverer`

**State values:**

| State | Directory suffix | Meaning |
|---|---|---|
| `active` | `.active` | Production-ready; symlinks exist |
| `review` | `.review` | Under evaluation; no symlinks |
| `deactivated` | `.deactivated` | Temporarily disabled; no symlinks |
| `decommissioned` | `.decommissioned` | Permanently retired; no symlinks |

## SKILL.md Format

Each skill directory must contain a `SKILL.md` file with a YAML frontmatter block:

```markdown
---
name: <name>
description: <one-line description>
disable-model-invocation: true
---

# Skill body (optional, skill-specific content)
```

### Required Frontmatter Fields

| Field | Type | Rules |
|---|---|---|
| `name` | string | Must exactly match the directory name prefix (before the last `.`) |
| `description` | string | Non-empty; one line; describes what the skill does and when to invoke it |
| `disable-model-invocation` | boolean | Must be `true` — prevents recursive skill invocation |

### Example: Expertise Skill

```markdown
---
name: architect
description: Apply systems architect expertise for HLD generation and design reviews. Invoke when designing new systems or validating architectural patterns.
disable-model-invocation: true
---

# System Architect Expertise

- **Focus**: Hexagonal Architecture, Clean Architecture, and SoC.
- **Standards**: C4 Model hierarchy; ADRs for all structural decisions.
- **Mandatory Tasks**:
    1. Validate boundaries between Domain, Application, and Infrastructure layers.
    2. Enforce Dependency Injection patterns.
- **Constraints**: No infrastructure leaks into the domain layer.
```

### Example: Workflow Skill

```markdown
---
name: git-commit
description: Guide a structured git commit workflow with staged diff review and confirmation gate. Invoke when committing changes to a repository.
disable-model-invocation: true
---

# Git Commit Workflow

## Steps

### 1. Inspect staged changes
Run `git diff --staged` and summarise what will be committed.

### 2. Draft commit message
Write a concise message: imperative mood, ≤72 chars subject line.

### 3. Confirm with user
Present the diff summary and message. Do not commit without explicit approval.

### 4. Execute
Upon approval: `git commit -m "<message>"`. Verify with `git log --oneline -1`.
```

## Reference Files

For content longer than ~10 lines that is only needed in specific steps, extract it into a `references/` subdirectory and link lazily:

```
manage-skills.active/
  SKILL.md
  references/
    marketplace-overlap.md
    mcp-playbook.md
```

In `SKILL.md`, add a `## References` section:

```markdown
## References

- `references/marketplace-overlap.md` — plugin conflict data; read during activation only
- `references/mcp-playbook.md` — MCP server setup; read only when asked about MCP infrastructure
```

This keeps `SKILL.md` lean and avoids loading large content on every invocation.

## Validation

Run `agents audit` to validate all `SKILL.md` files. CI enforces these rules automatically on every PR via `.github/workflows/validate.yml`.
