# Git Repo Create Subflow

Creates a new repository on GitHub or GitLab, then wires up the local remote.

## Workflow

### 1. Detect Provider

If already in a git repository, run `git remote get-url origin` to detect the platform:
- URL contains `github.com` → provider is **GitHub**.
- URL contains `gitlab.com` → provider is **GitLab**.
- No remote or ambiguous URL → ask:
  ```
  Platform? (1) GitHub  (2) GitLab
  ```

### 2. Collect Details

Ask in order:
1. **Repository name** — must be provided.
2. **Visibility** — Private (default) or Public.
3. **Description** — optional, one line.

### 3. Confirm

```
Create repository:
──────────────────
Provider:    <provider>
Name:        <name>
Visibility:  <private|public>
Description: <description>

Proceed? (yes / cancel)
```

### 4. Create

**GitHub:**
```bash
gh repo create <name> --<visibility> --source=. --remote=origin [--description "..."]
```
`--source=.` initialises the remote from the current directory when inside a git repo.

**GitLab:**
```bash
glab repo create <name> --<private|public> [--description "..."]
```
Then set the remote manually:
```bash
git remote add origin git@gitlab.com:<username>/<name>.git
# or update if origin already exists:
git remote set-url origin git@gitlab.com:<username>/<name>.git
```
Run `glab api user --jq '.username'` to resolve the username.

### 5. Confirm Setup

```bash
git remote -v          # verify remote is set
git push -u origin <current-branch>   # offer to push initial commit
```

Ask: "Push current branch to the new repository? (yes / no)"

## Guidelines

- **Check auth first** — run `gh auth status` or `glab auth status` before creating. If unauthenticated, stop and prompt the user to log in.
- **Never overwrite an existing remote** without confirming with the user.
- **Do not initialise a new git repo** in this subflow — that is out of scope. If `git init` is needed, inform the user and stop.
