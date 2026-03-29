# Workflow Skills

Workflow skills automate multi-step processes with a consistent safety model: gather information, propose a plan, confirm with the user, then execute. Nothing irreversible happens without explicit approval.

---

## How workflow skills work

A workflow skill defines a structured process — typically 4 steps:

1. **Gather** — collect the information needed
2. **Draft / Plan** — propose what will happen
3. **Confirm** — present the proposal and wait for approval
4. **Execute** — act on approval only

Complex workflows delegate to **subflows** — narrower processes that handle a specific operation within the parent workflow. Subflows are loaded lazily: only the relevant one is loaded when needed.

---

## Workflow skills available

| Skill | What it automates |
|---|---|
| `git-wf` | Routes Git operations to `github-wf` or `gitlab-wf` based on remote |
| `github-wf` | GitHub: PRs, releases, issues, branches via `gh` |
| `gitlab-wf` | GitLab: MRs, pipelines, branches via `glab` |
| `document-wf` | Create, review, update, or extend documents |
| `mermaid-wf` | Generate and validate Mermaid diagrams |
| `terraform-wf` | Scaffold Terraform HCL for new resources or modules |
| `gcp-wf` | Inventory existing GCP resources via `gcloud` |
| `skills-wf` | Create, audit, propose, and refine skills |
| `memory-wf` | Update memory files with before/after confirmation |
| `content-wf` | Social posts, video scripts, and written guides |

---

## Structure of a workflow skill

```
skills/workflow/<name>-wf/
  SKILL.md              — the workflow definition (required)
  subflows/             — optional, narrow sub-processes
    <name>-<action>-sf.md
  references/           — optional, static lookup data
    <name>.md
```

---

## Activation and deactivation

**Activated:** when the user invokes a workflow skill by name (e.g. `git-wf`) or when another workflow routes to it (e.g. `git-wf` activates `github-wf`). Symlink created in `~/.claude/skills/`; skill loaded for the current session.

**Deactivated:** when `skillforge deactivate <name>` is run. The symlink is removed; the skill directory moves to `skills/deactivated/workflow/<name>/`.

**Subflow activation:** subflow files inside `subflows/` are loaded lazily — only the subflow matching the user's current intent is loaded. They do not have symlinks; they are read directly by the parent workflow.

---

## Creating a new workflow skill

```bash
cp templates/workflow/subflow-skill.md skills/workflow/<name>-wf/SKILL.md
skillforge activate <name>-wf
```

Rules for workflow skills:
- The `name:` field must equal the directory name (e.g. `name: my-skill-wf`)
- Always confirm before any irreversible action
- Delegate state changes (activate, deactivate) to the `skillforge` CLI — never manage symlinks directly
- Keep `SKILL.md` under 30 lines; move detail into subflows or references
- Subflows live in a `subflows/` subdirectory and are loaded lazily
