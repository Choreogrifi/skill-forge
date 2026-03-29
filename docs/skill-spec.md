---
title: SKILL.md Specification
---

# SKILL.md Specification

## Directory Naming

Every skill is a directory under `$SKILLFORGE_DIR/skills/`. Directory location encodes the skill's lifecycle state; the directory name encodes its identity only.

**Name rules:**
- Lowercase letters, digits, and hyphens only; must start with a letter
- SME skills end with `-sme` (e.g. `architect-sme`, `security-sme`)
- Workflow skills end with `-wf` (e.g. `git-wf`, `terraform-wf`)

**Lifecycle state** is determined by directory location:

| State | Location | LLM visibility |
|---|---|---|
| `active` | `skills/{sme,workflow}/<name>/` | Visible (symlinks exist in production) |
| `staging` | `skills/staging/{sme,workflow}/<name>/` | Test only (symlinks in `skills-staging/` only) |
| `review` | `skills/review/{sme,workflow}/<name>/` | Hidden (no symlinks) |
| `deactivated` | `skills/deactivated/{sme,workflow}/<name>/` | Hidden (no symlinks) |
| `decommissioned` | `skills/decommissioned/{sme,workflow}/<name>/` | Hidden (no symlinks) |

Transitioning between states is a directory move. The `name:` field in `SKILL.md` is always just the skill name — it never includes a state suffix.

## SKILL.md Format

Each skill directory must contain a `SKILL.md` file with a YAML frontmatter block followed by the skill body:

```markdown
---
name: <skill-name>
description: <one-line description — what it does and when to invoke it>
metadata:
  skill-type: sme-persona | workflow | system
  version: "1.0"
  memory-file: <group>/<skill-name>.md
  related-skills: [<skill-a>, <skill-b>]
  disable-model-invocation: true
---

# Skill body
```

### Required Frontmatter Fields

| Field | Type | Rules |
|---|---|---|
| `name` | string | Must exactly match the directory name (e.g. `git-sme`) |
| `description` | string | Non-empty; one line; describes what the skill does and when to invoke it |
| `metadata.skill-type` | string | One of: `sme-persona`, `workflow`, `system` |
| `metadata.version` | string | Semantic version string (e.g. `"1.0"`) |
| `metadata.disable-model-invocation` | boolean | Must be `true` — prevents recursive skill invocation |

### Optional Frontmatter Fields

| Field | Type | Purpose |
|---|---|---|
| `metadata.memory-file` | string | Path to the skill's memory file relative to `$SKILLFORGE_DIR/memory/` |
| `metadata.related-skills` | list | Skills that this skill activates or coordinates with |

### Example: SME Skill

```markdown
---
name: architect-sme
description: Apply systems architect expertise for HLD generation and design reviews. Invoke when designing new systems or validating architectural patterns.
metadata:
  skill-type: sme-persona
  version: "1.0"
  memory-file: sme/architect.md
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

### Example: Workflow Skill with Subflows

```markdown
---
name: git-wf
description: Git operations router. Detects GitHub or GitLab and routes to the correct sub-skill. Invoke for any git or platform operation.
metadata:
  skill-type: workflow
  version: "1.0"
  memory-file: workflow/git.md
  related-skills: [github-wf, gitlab-wf]
  disable-model-invocation: true
---

# Manage Git

## Workflow
### 1. Detect Provider
...

## Subflows
| File | Load when |
|---|---|
| `subflows/git-clone-sf.md` | User wants to clone a repository |
| `subflows/git-branch-sf.md` | User wants branch operations |
```

## Directory Structure

```
skills/
  sme/
    <name>-sme/
      SKILL.md                — required
      references/             — optional, lazy-loaded static docs
        <name>.md
  workflow/
    <name>-wf/
      SKILL.md                — required
      subflows/               — optional, lazy-loaded sub-processes
        <name>-<action>-sf.md
      references/             — optional, static lookup data
        <name>.md
  staging/
    sme/<name>-sme/
    workflow/<name>-wf/
  deactivated/
    sme/<name>-sme/
    workflow/<name>-wf/
  review/
    sme/<name>-sme/
    workflow/<name>-wf/
  decommissioned/
    sme/<name>-sme/
    workflow/<name>-wf/
```

## Subflow Convention

Subflows live in `subflows/` inside a workflow skill. They are not symlinked and have no frontmatter — they are plain Markdown loaded lazily by the parent workflow when the user's intent matches.

Subflow file names follow: `<parent-skill>-<action>-sf.md`
Examples: `git-clone-sf.md`, `document-readme-sf.md`, `mermaid-write-sf.md`

## Reference Files

For static content longer than ~10 lines that is only needed in specific steps, extract it into `references/` and link lazily in the `## References` section of `SKILL.md`.

## Validation

Run `skillforge audit` to validate all `SKILL.md` files locally. CI enforces these rules automatically on every PR via `.github/workflows/validate.yml`.
