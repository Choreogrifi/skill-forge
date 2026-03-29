# Refine Skill Subflow

Guides the user through reviewing and improving an existing skill's SKILL.md.
All changes require explicit approval before writing.

## When to Use

Invoke when the user wants to improve an existing skill — sharpen its description,
reduce its token footprint, fix frontmatter, or add/remove references.

## Workflow

### 1. Identify the Skill

Ask: `Which skill do you want to refine? (name or path)`

Run `skillforge ls` if the user is unsure.

Read the skill's SKILL.md in full.

### 2. Diagnose Issues

Check against the quality criteria:

| Criterion | Check |
|---|---|
| Token budget | SKILL.md ≤ 30 lines (move overflow to references/) |
| Frontmatter | `name`, `version`, `metadata.skill-type`, `metadata.description`, `metadata.disable-model-invocation: true` |
| Name match | frontmatter `name` == folder name (minus state suffix) |
| Generic top level | SME skills must not reference specific technologies at the top level |
| Single responsibility | Does this skill do exactly one thing? |
| Memory file | Is `metadata.memory-file` referenced correctly and does the file exist? |
| References | Are referenced files under `references/` and do they exist? |

Present findings:

```
Skill: <name>
──────────────────────────────────
CRITICAL
  [ ] <issue> — <recommendation>

IMPROVEMENT
  [ ] <issue> — <recommendation>

PASSED
  [x] <criterion>
```

### 3. Propose Changes

For each issue, propose the specific change as a before/after diff.
Present all proposed changes together for a single approval:

```
Proposed changes to SKILL.md:
────────────────────────────
<diff>
────────────────────────────
Apply all changes? (yes / edit / cancel)
```

### 4. Write on Approval

Write the updated SKILL.md. Confirm:
```
Updated: <path>
Run: skillforge audit   — to verify the changes pass all checks
```

## Guidelines

- Never reduce the functional content of a skill without understanding what it does.
- If content needs to move to a `references/` file, create that file as part of the same approval.
- If fixing a `memory-file` reference to a non-existent file, offer to create the stub via `memory-manager-wf`.
- Validate the updated skill with `skillforge audit` after writing.
