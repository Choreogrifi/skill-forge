# Skill Forge

[![Validate](https://github.com/Choreogrifi/skill-forge/actions/workflows/validate.yml/badge.svg)](https://github.com/Choreogrifi/skill-forge/actions/workflows/validate.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Docs](https://img.shields.io/badge/docs-skill--forge-blue)](https://choreogrifi.github.io/skill-forge/)

**Skill Forge gives your AI assistant a permanent memory and a set of expert skills, so it does better work and costs less to run.**

---

## What it does

- **Remembers you.** Tell the AI your preferences once — your tech stack, working style, code standards — and it remembers them across every session. No more repeating yourself.
- **Works like a specialist.** Activate a skill and your AI immediately knows the deep conventions for that domain: Git hygiene, Terraform patterns, security reviews, technical writing, and more.
- **Loads only what it needs.** Skills and memory are loaded on demand and unloaded when done. You never pay tokens for context you are not using.

---

## Install in 30 seconds

**Homebrew (macOS / Linux):**
```bash
brew tap choreogrifi/skill-forge && brew install skill-forge
```

**curl one-liner:**
```bash
curl -fsSL https://raw.githubusercontent.com/Choreogrifi/skill-forge/main/scripts/install.sh | bash
source ~/.zshrc
```

The installer asks which AI tools you use (Claude, Gemini), detects your installed tools (git, gh, gcloud, terraform), and sets everything up.

---

## Three quick examples

**1. Git expertise on demand**
```
User:   I need to resolve a merge conflict in src/api/handler.ts

With git-sme active:
AI:     Reads both sides of the conflict, explains the trade-off,
        proposes the resolved content, and waits for your approval
        before writing.
```

**2. Infrastructure scaffolding**
```
User:   Add a new Cloud Run job for the order processor

With terraform-sme + terraform-creator-wf active:
AI:     Discovers your existing terraform folder, reads your naming
        conventions, drafts the full HCL module, and confirms before
        writing a single file.
```

**3. Content in your voice**
```
User:   Write a LinkedIn post about our new open-source release

With content-creator-sme active:
AI:     Asks for your audience and tone, drafts a post in your brand
        voice with the right LinkedIn formatting, and iterates until
        you approve.
```

---

## How it works

**Skills** are small text files that tell the AI what to focus on and how to behave. When you activate a skill, it is symlinked into your AI tool's skills directory and loaded into the next session. When you deactivate it, the symlink is removed and it is no longer loaded. No files are ever deleted — state lives in the filesystem.

**Memory files** are separate documents that hold things the AI should remember about you: your role, your project conventions, your preferences. They are loaded at session start and written only when you explicitly say "remember this." They stay small because every line you load costs tokens.

```bash
skillforge ls          # see all your skills and their states
skillforge activate git-sme      # add Git expertise to your next session
skillforge deactivate terraform-sme   # stop loading it
skillforge audit       # fix any broken symlinks automatically
skillforge doctor      # check your environment
```

---

## Skill catalogue

### Expertise skills (SME)

| Skill | What it does |
|---|---|
| `architect-sme` | Systems architecture: Hexagonal/Clean patterns, ADRs, C4 diagrams |
| `engineer-sme` | Software implementation: SOLID, DI setup, strict typing |
| `devops-sme` | IaC, CI/CD pipelines, cloud infrastructure automation |
| `security-sme` | IAM reviews, secret management, OWASP vulnerability assessment |
| `tester-sme` | Test strategy, unit/integration test generation, TDD guidance |
| `git-sme` | Git concepts: branching strategy, commit hygiene, conflict resolution |
| `terraform-sme` | Terraform IaC design, module structure, state management |
| `gcp-sme` | Google Cloud Platform: resource design, IAM, service selection |
| `diagram-sme` | Architecture and flow diagrams across formats (Mermaid, PlantUML, etc.) |
| `document-sme` | Technical writing: READMEs, HLDs, ADRs, onboarding guides |
| `skills-sme` | Create, audit, and manage Skill Forge skills |
| `content-creator-sme` | Social media, video scripts, and written guides |

### Workflow skills

| Skill | What it does |
|---|---|
| `manage-git-wf` | Route Git/GitHub/GitLab operations with confirmation gates |
| `manage-github-wf` | GitHub PRs, releases, issues via `gh` CLI |
| `manage-gitlab-wf` | GitLab MRs, pipelines via `glab` CLI |
| `git-commit-wf` | Draft a commit message from your staged changes |
| `document-writer-wf` | Create, review, update, or extend any document |
| `write-readme-wf` | Draft a production-quality README.md |
| `review-document-wf` | Score a document and return prioritised improvements |
| `update-document-wf` | Edit specific sections with before/after confirmation |
| `add-document-wf` | Append content to an existing document |
| `mermaid-drawer-wf` | Generate and validate Mermaid diagram code |
| `terraform-creator-wf` | Scaffold Terraform HCL for a new resource or module |
| `terraform-discoverer-wf` | Infer required infrastructure from application code |
| `gcp-project-discoverer-wf` | Produce a structured inventory of an existing GCP project |
| `manage-skills-wf` | Create, audit, propose, and refine skills |
| `memory-manager-wf` | Update memory files with before/after confirmation |
| `create-content-wf` | Create social media posts, video scripts, or written guides |

---

## Personalise it

After install, use the `memory-wf` skill to build up memory as you work:

```bash
# See what memory files are loaded and their token cost
skillforge memory-help
```

Keep memory files focused. Every line you add is loaded into every session.

---

## Contribute

1. Fork the repository
2. Create a branch: `git checkout -b feat/add-<skill-name>`
3. Add or edit skills following the [Skill Spec](https://choreogrifi.github.io/skill-forge/skill-spec)
4. Validate: `bash -n scripts/skillforge.sh && skillforge audit`
5. Run tests: `bats tests/test_skillforge.bats`
6. Open a pull request — CI validates all SKILL.md files automatically

New skills must be generic (no personal data, no hardcoded paths) and follow the single-responsibility principle. See `skills/README.md` for full guidelines.

---

[MIT License](LICENSE) — [Documentation](https://choreogrifi.github.io/skill-forge/) — [Report an issue](https://github.com/Choreogrifi/skill-forge/issues)
