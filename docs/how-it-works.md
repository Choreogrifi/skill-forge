---
title: How It Works
---

# How It Works

## The Filesystem as State

skill-forge has no database, no config files, and no background services. The filesystem **is** the state.

Every skill is a directory. Its **location** encodes its lifecycle state:

```
skills/sme/architect-sme/            ← active
skills/workflow/git-wf/              ← active
skills/review/sme/engineer-sme/      ← under review
skills/deactivated/workflow/gcp-wf/  ← temporarily off
skills/decommissioned/sme/old-sme/   ← permanently retired
```

Skill names contain only lowercase letters, numbers, and hyphens. No dots, no state suffixes.

## Four States

| State | Location | LLM visibility |
|---|---|---|
| `active` | `skills/{sme,workflow}/<name>/` | Visible (symlinks exist) |
| `review` | `skills/review/{sme,workflow}/<name>/` | Hidden (no symlinks) |
| `deactivated` | `skills/deactivated/{sme,workflow}/<name>/` | Hidden (no symlinks) |
| `decommissioned` | `skills/decommissioned/{sme,workflow}/<name>/` | Hidden (no symlinks) |

Transitioning between states is a directory move (`mv`). No metadata to update. No database to sync.

## Symlinks as the Visibility Gate

LLM agents (Claude, Gemini) discover skills by scanning their designated directories:

```
~/.claude/skills/
~/.gemini/skills/
```

When a skill is **active**, a symlink is created in each of these directories pointing to the skill directory:

```
~/.claude/skills/architect-sme  →  $SKILLFORGE_DIR/skills/sme/architect-sme/
~/.gemini/skills/architect-sme  →  $SKILLFORGE_DIR/skills/sme/architect-sme/
```

When a skill is **not active**, those symlinks do not exist. The agent cannot see the skill.

Visibility is controlled entirely at the filesystem level — no agent config, no allowlists, no restart required.

## The Invariant

There is one rule that must always hold:

> `skill in skills/sme/ or skills/workflow/` ↔ symlinks exist in `~/.claude/skills/`

The `skillforge audit` command detects and repairs violations automatically.

## The `SKILLFORGE_DIR` Variable

All paths are derived from `SKILLFORGE_DIR` (default: `~/.skillforge`, configured at install time):

```bash
SKILLFORGE_DIR="${SKILLFORGE_DIR:-$HOME/.skillforge}"
SKILLS_DIR="${SKILLFORGE_DIR}/skills"
```

Override it to run against a test environment without touching live data:

```bash
SKILLFORGE_DIR=/tmp/sf-test skillforge ls
```

## CLI vs LLM — Division of Responsibility

The `skillforge` CLI and the LLM skills cover distinct concerns:

| Capability | CLI (`skillforge`) | LLM (skills) |
|---|---|---|
| Skill lifecycle (activate, deactivate, review, rm) | ✓ | — |
| Skill creation and authoring | — | ✓ via `skills-wf` |
| Git operations (commit, push, branch, clone…) | ✓ via `skillforge git` | ✓ via `git-wf` |
| GitHub PRs / GitLab MRs | ✓ via `skillforge git pr/mr` | ✓ via `github-wf` / `gitlab-wf` |
| Skill naming gate on commit | ✓ built into `skillforge git commit` | ✓ built into `git-wf` |

Git is available in both because the CLI is used outside of an LLM session (e.g. in CI, pre-commit hooks, or terminal workflows). The LLM path adds interactive guidance and dry-run summaries; the CLI path is for scripted or fast terminal use.

## CLI vs LLM — Division of Responsibility

The `skillforge` CLI and the LLM skills cover distinct concerns:

| Capability | CLI (`skillforge`) | LLM (skills) |
|---|---|---|
| Skill lifecycle (activate, deactivate, review, rm) | ✓ | — |
| Skill creation and authoring | — | ✓ via `skills-wf` |
| Git operations (commit, push, branch, clone…) | ✓ via `skillforge git` | ✓ via `git-wf` |
| GitHub PRs / GitLab MRs | ✓ via `skillforge git pr/mr` | ✓ via `github-wf` / `gitlab-wf` |
| Skill naming gate on commit | ✓ built into `skillforge git commit` | ✓ built into `git-wf` |

Git is available in both because the CLI is used outside of an LLM session (e.g. in CI, pre-commit hooks, or terminal workflows). The LLM path adds interactive guidance and dry-run summaries; the CLI path is for scripted or fast terminal use.

## Why No Database?

- **Observability**: `skillforge ls` or `ls $SKILLFORGE_DIR/skills/` shows the complete system state instantly.
- **Durability**: No corruption risk — there's nothing to corrupt beyond a directory rename.
- **Portability**: The entire skill set is a directory tree. Copy it, version it, back it up with standard tools.
- **Debuggability**: `find`, `ls -la`, and `readlink` are sufficient to diagnose any issue.

## Two Skill Types

Skills are either **SME** (Subject Matter Expertise) or **Workflow**:

| Type | Suffix | Purpose | Loaded |
|---|---|---|---|
| SME | `-sme` | Domain expertise — standards, constraints, what to look for | On demand per domain |
| Workflow | `-wf` | Step-by-step processes — gather, plan, confirm, execute | On demand per operation |

SME skills define *how to think*. Workflow skills define *what steps to take*. They complement each other: `terraform-wf` runs the Terraform scaffolding process; `terraform-sme` ensures the output meets IaC standards.

## Cross-Skill Delegation

Workflow skills can activate other skills. The `related-skills` metadata field declares these dependencies:

```
git-wf         →  github-wf  or  gitlab-wf      (router pattern)
terraform-wf   →  terraform-sme, gcp-sme         (expertise injection)
document-wf    →  document-sme, mermaid-wf        (specialist delegation)
```

When `git-wf` detects a GitHub remote, it activates `github-wf` and hands off all further interaction. When `terraform-wf` encounters a live GCP project, it invokes `gcp-wf` to get a resource inventory before generating HCL.

## Memory System

Memory files give the AI context that persists across sessions. They are organised into two skill-scoped groups:

| Group | Directory | Loaded when |
|---|---|---|
| SME | `memory/sme/` | When the linked SME skill is invoked |
| Workflow | `memory/workflow/` | When the linked workflow is invoked |

Each memory file is linked to one skill via the `memory-file:` frontmatter field. When a skill is deactivated, its memory file is archived. When reactivated, it is restored.

Memory files are capped at 40 lines. If a file grows beyond that, split it into two scoped files.

## Session Memory and `/clear`

Only `model.md` (your persona file, symlinked to `CLAUDE.md`) persists after `/clear`. All invoked skill context is removed. Skills remain available as slash commands and can be re-invoked in the new session.

**System skills** (skill detection, memory management) operate in one of two modes set at install:

| Mode | Behaviour |
|---|---|
| Always-on | Rules embedded in `model.md` — active every session, survive `/clear` |
| Manual | Invoked as `/skills-sme` or `/memory-wf` when needed — cleared by `/clear` |

Switch modes at any time: invoke `/memory-wf` → "toggle system skills".

## Subflows

Workflow skills can delegate to **subflows** — narrow processes that handle one specific operation within the parent workflow. Subflows are loaded lazily: only the matching one is loaded when needed.

```
git-wf
  └── subflows/
        git-clone-sf.md      ← loaded when user wants to clone
        git-branch-sf.md     ← loaded when user wants branch operations
        git-conflict-sf.md   ← loaded when resolving merge conflicts
```

Subflows have no frontmatter, no symlinks, and no metadata — they are plain Markdown read directly by the parent workflow.

## Self-Discovery

Every workflow skill that has an improve-type subflow (e.g. `mermaid-improve-sf`) follows the same standard pattern:

1. **Discover** — audit the relevant content using the skill's read/audit subflow
2. **Plan** — present findings as a structured improvement plan (plan mode only)
3. **User approves** — no changes without explicit confirmation
4. **Apply** — each change shown as before/after diff
5. **PR** — a pull request is created via `git-wf` → `github-wf` for repository owner review

## Two Skill Types

Skills are either **SME** (Subject Matter Expertise) or **Workflow**:

| Type | Suffix | Purpose | Loaded |
|---|---|---|---|
| SME | `-sme` | Domain expertise — standards, constraints, what to look for | On demand per domain |
| Workflow | `-wf` | Step-by-step processes — gather, plan, confirm, execute | On demand per operation |

SME skills define *how to think*. Workflow skills define *what steps to take*. They complement each other: `terraform-wf` runs the Terraform scaffolding process; `terraform-sme` ensures the output meets IaC standards.

## Cross-Skill Delegation

Workflow skills can activate other skills. The `related-skills` metadata field declares these dependencies:

```
git-wf         →  github-wf  or  gitlab-wf      (router pattern)
terraform-wf   →  terraform-sme, gcp-sme         (expertise injection)
document-wf    →  document-sme, mermaid-wf        (specialist delegation)
```

When `git-wf` detects a GitHub remote, it activates `github-wf` and hands off all further interaction. When `terraform-wf` encounters a live GCP project, it invokes `gcp-wf` to get a resource inventory before generating HCL.

## Memory System

Memory files give the AI context that persists across sessions. They are organised into two skill-scoped groups:

| Group | Directory | Loaded when |
|---|---|---|
| SME | `memory/sme/` | When the linked SME skill is invoked |
| Workflow | `memory/workflow/` | When the linked workflow is invoked |

Each memory file is linked to one skill via the `memory-file:` frontmatter field. When a skill is deactivated, its memory file is archived. When reactivated, it is restored.

Memory files are capped at 40 lines. If a file grows beyond that, split it into two scoped files.

## Session Memory and `/clear`

Only `model.md` (your persona file, symlinked to `CLAUDE.md`) persists after `/clear`. All invoked skill context is removed. Skills remain available as slash commands and can be re-invoked in the new session.

**System skills** (skill detection, memory management) operate in one of two modes set at install:

| Mode | Behaviour |
|---|---|
| Always-on | Rules embedded in `model.md` — active every session, survive `/clear` |
| Manual | Invoked as `/skills-sme` or `/memory-wf` when needed — cleared by `/clear` |

Switch modes at any time: invoke `/memory-wf` → "toggle system skills".

## Subflows

Workflow skills can delegate to **subflows** — narrow processes that handle one specific operation within the parent workflow. Subflows are loaded lazily: only the matching one is loaded when needed.

```
git-wf
  └── subflows/
        git-clone-sf.md      ← loaded when user wants to clone
        git-branch-sf.md     ← loaded when user wants branch operations
        git-conflict-sf.md   ← loaded when resolving merge conflicts
```

Subflows have no frontmatter, no symlinks, and no metadata — they are plain Markdown read directly by the parent workflow.

## Self-Discovery

Every workflow skill that has an improve-type subflow (e.g. `mermaid-improve-sf`) follows the same standard pattern:

1. **Discover** — audit the relevant content using the skill's read/audit subflow
2. **Plan** — present findings as a structured improvement plan (plan mode only)
3. **User approves** — no changes without explicit confirmation
4. **Apply** — each change shown as before/after diff
5. **PR** — a pull request is created via `git-wf` → `github-wf` for repository owner review
