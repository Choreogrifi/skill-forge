# Propose Skill Subflow

Guides the user through proposing a new skill for the Skill Forge repository.
Creates a local draft for review and optionally submits a pull request.

## When to Use

Invoke when the user explicitly wants to contribute a new skill to the shared
Skill Forge repository — not just create a skill for personal use.

## Workflow

### 1. Check for Existing Skills

Before proposing, prevent duplication:

```bash
skillforge ls
```

Also read `references/marketplace-overlap.md`. If a skill already covers the
requested use case, show the existing skill and ask: `Does the existing skill
cover your need, or is this genuinely new?`

### 2. Gather Proposal Details

Ask the user:

```
New skill proposal:
  Skill name (lowercase, hyphen-separated, ends with -sme or -wf):
  Skill type: sme-persona / workflow / system
  One-line description (what it does and when to invoke it):
  Problem it solves (why does this need to be a skill?):
  Who would use it? (e.g. developers, DevOps engineers, all users):
  Does it depend on any external tools? (e.g. gh, gcloud, terraform):
```

### 3. Create Local Draft

Using the appropriate template:
- `sme-persona` → `templates/sme/{sme-name}-sme.md`
- `workflow` → `templates/subflow/{sme-name}-{action}-sf.md`

Write the draft to `${SKILLFORGE_DIR}/skills/<type>/<name>.active/SKILL.md`.

Present the draft to the user and ask:
```
Review the draft above.
  1. Accept and proceed to PR
  2. Edit the draft
  3. Save locally only (no PR)
  4. Discard

Enter 1–4:
```

### 4. Submit Pull Request (if user selects 1)

Activate `manage-git-wf` and hand off with the instruction:
```
Create a pull request for the new skill at skills/<type>/<name>.active/
Branch name: feat/add-<name>
Title: feat(skills): add <name>
Body: include the SKILL.md content as the PR description
```

### 5. Confirm Outcome

```
Skill proposal saved to: ${SKILLFORGE_DIR}/skills/<type>/<name>.active/
[PR created: <url>]

Run: skillforge activate <name>   — to start using it locally
```

## Guidelines

- Never submit a PR with personal data, hardcoded paths, or credentials in any skill file.
- The PR description must include the SKILL.md content so reviewers can evaluate without checking out the branch.
- If the user declines to submit a PR, the skill is still saved locally and fully functional.
