# Git Repo Rename Subflow

Renames a repository on GitHub or GitLab, then updates the local remote URL to match.

## Workflow

### 1. Read Current Remote

Run `git remote get-url origin` to get the current remote URL.

- If no `origin` remote exists: stop and inform the user.
- Detect provider from the URL (`github.com` → GitHub, `gitlab.com` → GitLab).
- Parse the **owner** and **repository name** from the URL.

For SSH URLs: `git@github.com:<owner>/<repo>.git`
For HTTPS URLs: `https://github.com/<owner>/<repo>.git`

### 2. Ask for New Name

```
Current: <owner>/<repo> (<provider>)
New repository name:
```

Validate: name must not be empty, must not match the current name.

### 3. Derive New Remote URL

Preserve the original protocol (SSH or HTTPS):
- SSH:   `git@<provider>.com:<owner>/<new-name>.git`
- HTTPS: `https://<provider>.com/<owner>/<new-name>.git`

### 4. Confirm

```
Rename repository:
──────────────────
Provider:       <provider>
Old name:       <owner>/<old-name>
New name:       <owner>/<new-name>
New remote URL: <new-url>

Proceed? (yes / cancel)
```

### 5. Rename on Platform

**GitHub:**
```bash
gh repo rename <new-name>
```
(Detects the current repo from the remote — must be run from inside the git directory.)

**GitLab:**
```bash
glab api "projects/<owner>%2F<old-name>" -X PUT -f "name=<new-name>" -f "path=<new-name>"
```

### 6. Update Local Remote URL

```bash
git remote set-url origin <new-url>
```

Verify:
```bash
git remote -v
```

### 7. Confirm Outcome

```
Repository renamed to '<new-name>'.
Remote 'origin' updated to: <new-url>
```

Remind the user: any open PRs/MRs may reference the old URL. GitHub redirects automatically; GitLab may require updating CI/CD variables.

## Guidelines

- **Check auth first** — run `gh auth status` or `glab auth status` before the rename. Stop if unauthenticated.
- **Owner cannot change** — this subflow only renames the repository, not its owner or namespace. For a namespace move, use the platform UI.
- **Never force** — if the rename fails on the platform, do not update the local remote. Both changes succeed or neither does.
