---
title: Skill Catalog
---

# Skill Catalog

All built-in skills included with skill-forge. Skills are organised into two categories:
**SME** (Subject Matter Expertise) and **Workflow**.

---

## SME Skills

SME skills give the AI deep domain knowledge. When active, the AI applies the skill's standards and constraints to every response in the session.

| Skill | Domain | Memory | Related Skills |
|---|---|---|---|
| `architect-sme` | Systems architecture — Hexagonal/Clean, ADRs, C4 diagrams | `sme/architect.md` | — |
| `engineer-sme` | Software implementation — SOLID, DI, strict typing | `sme/engineer.md` | — |
| `devops-sme` | IaC, CI/CD, Cloud Build, observability | `sme/devops.md` | `security-sme`, `terraform-sme` |
| `security-sme` | IAM, secrets, OWASP, vulnerability assessment | `sme/security.md` | — |
| `tester-sme` | Test strategy, TDD, unit/integration tests | `sme/tester.md` | — |
| `git-sme` | Git concepts — branching, commits, conflicts, history | — | — |
| `terraform-sme` | Terraform IaC design, modules, state management | `sme/terraform.md` | — |
| `gcp-sme` | Google Cloud Platform — resources, IAM, managed services | `sme/gcp.md` | — |
| `diagram-sme` | Diagram type selection and format-agnostic expertise | — | — |
| `document-sme` | Technical writing — READMEs, HLDs, ADRs | `sme/document.md` | — |
| `skills-sme` | Creating and managing Skill Forge skills | — | — |
| `content-creator-sme` | Social media, video scripts, written guides | `sme/content-creator.md` | — |

---

## Workflow Skills

Workflow skills automate multi-step processes with a confirmation gate before any irreversible action. Complex workflows delegate to **subflows** — narrower processes loaded on demand.

| Skill | What it automates | Subflows | Related Skills |
|---|---|---|---|
| `git-wf` | Routes git operations to GitHub or GitLab | `git-clone-sf`, `git-branch-sf`, `git-conflict-sf`, `git-tag-sf` | `github-wf`, `gitlab-wf` |
| `github-wf` | GitHub: PRs, releases, issues, branches via `gh` | `github-pr-sf`, `github-release-sf` | — |
| `gitlab-wf` | GitLab: MRs, pipelines, branches via `glab` | `gitlab-mr-sf`, `gitlab-pipeline-sf` | — |
| `document-wf` | Create, review, update, or extend documents | `document-readme-sf`, `document-audit-sf`, `document-update-sf`, `document-extend-sf`, `document-adr-sf` | `document-sme`, `diagram-sme`, `mermaid-wf` |
| `mermaid-wf` | Generate, validate, and improve Mermaid diagrams | `mermaid-write-sf`, `mermaid-read-sf`, `mermaid-improve-sf` | — |
| `terraform-wf` | Scaffold Terraform HCL for new resources or modules | `terraform-scan-sf` | `terraform-sme`, `gcp-sme` |
| `gcp-wf` | Inventory existing GCP resources via `gcloud` | `gcp-discover-sf`, `gcp-scan-sf` | — |
| `skills-wf` | Create, audit, propose, and refine skills | `skills-create-sf`, `skills-audit-sf`, `skills-propose-sf`, `skills-refine-sf` | `skills-sme`, `memory-wf` |
| `memory-wf` | Update memory files with before/after confirmation | `memory-create-sf`, `memory-audit-sf` | — |
| `content-wf` | Social posts, video scripts, and written guides | `content-social-sf`, `content-video-sf` | `content-creator-sme` |

---

## Managing Skills

```bash
# List all skills and their states
skillforge ls

# Activate a skill (creates symlinks, makes it visible to AI)
skillforge activate git-sme

# Deactivate a skill (removes symlinks, keeps the skill on disk)
skillforge deactivate git-sme

# Put a skill in review (removes symlinks, flags for evaluation)
skillforge review git-sme

# Retire a skill permanently
skillforge rm git-sme

# Detect and repair any symlink violations
skillforge audit
```

See the [CLI Reference](cli.md) for the full command list.

---

## Creating a New Skill

```bash
# SME skill
cp templates/sme/\{sme-name\}-sme.md skills/sme/<your-skill>-sme/SKILL.md

# Workflow skill
cp templates/workflow/subflow-skill.md skills/workflow/<your-skill>-wf/SKILL.md
```

Fill in the placeholders, set `name:` to match the folder name (e.g. `name: my-skill-sme`), then activate:

```bash
skillforge activate <your-skill>-sme
```

See the [SKILL.md Specification](skill-spec.md) for the full format reference.
