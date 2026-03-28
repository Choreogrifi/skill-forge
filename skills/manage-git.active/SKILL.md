---
name: manage-git
skill-type: workflow
memory-file: workflow/manage-git.md
description: Git operations router for the current repository. Detects or asks whether the remote is GitHub or GitLab, then activates the correct sub-skill to handle the request with a confirmation gate before execution. Invoke for any git or platform operation on the current folder.
disable-model-invocation: true
---

# Manage Git

Routes git and platform operations to either `manage-github` or `manage-gitlab` based on the repository's remote. All destructive or remote-affecting actions require explicit user approval before execution.

## Workflow

### 1. Detect Provider

Run the following from the current directory:

```bash
git remote get-url origin 2>/dev/null
```

- If the URL contains `github.com` → set provider to **GitHub**, skip Step 2.
- If the URL contains `gitlab.com` or a known self-hosted GitLab pattern → set provider to **GitLab**, skip Step 2.
- If no remote exists or the URL is ambiguous → proceed to Step 2.

### 2. Ask Provider (if not auto-detected)

```
No remote detected or provider unclear.

Are you working with:
  1. GitHub
  2. GitLab

Enter 1 or 2:
```

### 3. Route to Sub-skill

- Provider is **GitHub** → activate `manage-github` and hand off all further interaction.
- Provider is **GitLab** → activate `manage-gitlab` and hand off all further interaction.

Inform the user which skill is being activated:
```
Routing to manage-github / manage-gitlab — ready for your request.
```

### 4. Pass-through

All subsequent user requests are handled entirely by the activated sub-skill. `manage-git` does not intercept or modify the sub-skill's confirmation gates or execution steps.

## Guidelines

- **Auto-detection first:** Always attempt to detect the provider from the remote URL before asking.
- **Never execute git commands directly:** All execution is delegated to the sub-skill.
- **One provider per session:** Once routed, do not re-prompt unless the user explicitly asks to switch.
- **Sub-skills are required:** If `manage-github` or `manage-gitlab` is not available at `/Users/leond/.claude/skills/`, inform the user and stop.

## Related Skills

- `manage-github` — handles all GitHub operations (PRs, issues, Actions, releases) and local git commands
- `manage-gitlab` — handles all GitLab operations (MRs, pipelines, CI/CD) and local git commands
