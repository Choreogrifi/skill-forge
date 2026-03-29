# SME Skills (Subject Matter Expertise)

SME skills give your AI assistant deep domain expertise. When active, the AI applies the knowledge, standards, and constraints defined in the skill's `SKILL.md` to every response in the session.

---

## How SME skills work

An SME skill does one thing: it defines a focused persona and a set of non-negotiable standards for a specific domain. It is small by design — every line is loaded into every session.

When you activate `git-sme`, the AI knows:
- Git branching conventions and when to rebase vs merge
- Commit hygiene rules (conventional commits, atomic changes)
- What to check before any rebase, reset, or destructive operation

It does **not** know GitHub-specific operations — that is the job of `github-wf`.

---

## SME skills available

| Skill | Domain |
|---|---|
| `architect-sme` | Systems architecture — Hexagonal/Clean, ADRs, C4 |
| `engineer-sme` | Software implementation — SOLID, DI, strict typing |
| `devops-sme` | IaC, CI/CD, cloud infrastructure automation |
| `security-sme` | IAM, secrets, OWASP, vulnerability assessment |
| `tester-sme` | Test strategy, TDD, unit/integration tests |
| `git-sme` | Git concepts — branching, commits, conflicts, history |
| `terraform-sme` | Terraform IaC design, modules, state |
| `gcp-sme` | Google Cloud Platform resources and IAM |
| `diagram-sme` | Diagrams — type selection and format-agnostic expertise |
| `document-sme` | Technical writing — READMEs, HLDs, ADRs |
| `skills-sme` | Creating and managing Skill Forge skills |
| `content-creator-sme` | Social media, video scripts, written guides |

---

## Structure of an SME skill

```
skills/sme/<name>-sme/
  SKILL.md           — the skill definition (required)
  references/        — optional supporting documents loaded lazily
    <name>.md
```

`SKILL.md` must stay under 30 lines. If it grows beyond that, move the excess into `references/`.

---

## Activation and deactivation

**Activated:** when the user explicitly invokes the skill by name (e.g. `architect-sme`) or when a workflow skill lists it in its `related-skills`. Symlink is created in `~/.claude/skills/` and the skill is loaded for all subsequent interactions in that session.

**Deactivated:** when `skillforge deactivate <name>` is run. The symlink is removed; the skill directory moves to `skills/deactivated/sme/<name>/`.

**Reviewing:** `skillforge review <name>` moves the directory to `skills/review/sme/<name>/` and removes the symlink. The skill is visible in `skillforge ls` but not loaded by the AI.

---

## Creating a new SME skill

Copy and fill in the template:
```bash
cp templates/sme/{sme-name}-sme.md skills/sme/<your-skill>-sme/SKILL.md
skillforge activate <your-skill>-sme
```

Rules for SME skills:
- The `name:` field must equal the directory name (e.g. `name: my-skill-sme`)
- Generic at the top level — no specific technologies in Focus, Standards, or Mandatory Tasks (those go in memory files or references)
- Single responsibility — one domain, done well
- No personal data, no hardcoded paths
