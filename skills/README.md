# Skills

This directory contains all Skill Forge skills, organised into two categories:

| Directory | Contains |
|---|---|
| `sme/` | Expertise skills — deep domain knowledge loaded on demand |
| `workflow/` | Workflow skills — step-by-step processes with confirmation gates |

---

## What is a skill?

A skill is a directory containing a `SKILL.md` file. That file tells your AI assistant what to focus on and how to behave when the skill is active.

When a skill is active (in `skills/sme/` or `skills/workflow/`), it is symlinked into `~/.claude/skills/` or `~/.gemini/skills/` and becomes available as a slash command. Skills in lifecycle subdirectories (`deactivated/`, `review/`, `decommissioned/`) have no symlinks and are invisible to the AI.

---

## Skill states

State is encoded by directory **location**, not by directory name:

| State | Location | Symlink |
|---|---|---|
| `active` | `skills/{sme,workflow}/<name>/` | Yes |
| `review` | `skills/review/{sme,workflow}/<name>/` | No |
| `deactivated` | `skills/deactivated/{sme,workflow}/<name>/` | No |
| `decommissioned` | `skills/decommissioned/{sme,workflow}/<name>/` | No |

Change state with the CLI:

```bash
skillforge activate <name>       # make active
skillforge deactivate <name>     # turn off
skillforge review <name>         # flag for review
skillforge rm <name>             # decommission
```

---

## How to create a skill

Use the `skills-wf` skill inside your AI session:

```
Activate skills-wf → it will guide you through naming, typing, and writing the SKILL.md
```

Or copy a template directly:
```bash
cp templates/sme/{sme-name}-sme.md skills/sme/<your-skill>-sme/SKILL.md
# or
cp templates/workflow/subflow-skill.md skills/workflow/<your-skill>-wf/SKILL.md
```

---

## Naming rules

- All lowercase, hyphen-separated
- SME skills end with `-sme` (e.g. `git-sme`, `security-sme`)
- Workflow skills end with `-wf` (e.g. `git-wf`, `terraform-wf`)
- No dots, no state suffixes in the name

The `name:` field in `SKILL.md` must exactly match the directory name:
```
Directory: git-sme   →  name: git-sme
Directory: git-wf    →  name: git-wf
```

Run `skillforge audit` to check for naming violations.
