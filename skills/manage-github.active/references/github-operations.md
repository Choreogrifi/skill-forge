# GitHub Operations Reference

Command syntax for local git and GitHub platform operations via `git` and `gh` CLIs.

---

## Local Git

| Operation | Command |
|---|---|
| Status | `git status` |
| Diff (unstaged) | `git diff` |
| Diff (staged) | `git diff --cached` |
| Log | `git log --oneline --graph --decorate -20` |
| Create branch | `git checkout -b <branch>` |
| Switch branch | `git checkout <branch>` |
| List branches | `git branch -a` |
| Delete branch (local) | `git branch -d <branch>` |
| Force delete branch | `git branch -D <branch>` |
| Merge branch | `git merge <branch>` |
| Rebase | `git rebase <base>` |
| Interactive rebase | `git rebase -i HEAD~<n>` |
| Stash | `git stash push -m "<message>"` |
| Stash list | `git stash list` |
| Stash pop | `git stash pop` |
| Cherry-pick | `git cherry-pick <commit>` |
| Tag | `git tag -a <tag> -m "<message>"` |
| Reset (soft) | `git reset --soft HEAD~<n>` |
| Reset (hard) | `git reset --hard <ref>` |
| Commit | `git commit -m "<message>"` |
| Amend commit | `git commit --amend --no-edit` |
| Push | `git push origin <branch>` |
| Push (set upstream) | `git push -u origin <branch>` |
| Force push (non-main) | `git push --force-with-lease origin <branch>` |
| Pull | `git pull origin <branch>` |
| Fetch | `git fetch --all --prune` |
| Remote URL | `git remote get-url origin` |

---

## Pull Requests

| Operation | Command |
|---|---|
| Create PR | `gh pr create --title "<title>" --body "<body>" --base <base> --head <head>` |
| Create PR (draft) | `gh pr create --draft --title "<title>" --body "<body>" --base <base>` |
| List open PRs | `gh pr list` |
| View PR | `gh pr view <number>` |
| View PR (browser) | `gh pr view <number> --web` |
| Checkout PR branch | `gh pr checkout <number>` |
| Merge PR (merge commit) | `gh pr merge <number> --merge` |
| Merge PR (squash) | `gh pr merge <number> --squash` |
| Merge PR (rebase) | `gh pr merge <number> --rebase` |
| Close PR | `gh pr close <number>` |
| Approve PR | `gh pr review <number> --approve` |
| Request changes | `gh pr review <number> --request-changes --body "<comment>"` |
| Add comment | `gh pr comment <number> --body "<comment>"` |
| List PR checks | `gh pr checks <number>` |
| Add reviewer | `gh pr edit <number> --add-reviewer <username>` |
| Add label | `gh pr edit <number> --add-label "<label>"` |

---

## Issues

| Operation | Command |
|---|---|
| Create issue | `gh issue create --title "<title>" --body "<body>"` |
| List issues | `gh issue list` |
| View issue | `gh issue view <number>` |
| Close issue | `gh issue close <number>` |
| Reopen issue | `gh issue reopen <number>` |
| Add comment | `gh issue comment <number> --body "<comment>"` |
| Assign issue | `gh issue edit <number> --add-assignee <username>` |
| Add label | `gh issue edit <number> --add-label "<label>"` |

---

## Actions / Workflows

| Operation | Command |
|---|---|
| List workflows | `gh workflow list` |
| View workflow runs | `gh run list --workflow <name>` |
| View run status | `gh run view <run-id>` |
| Watch run live | `gh run watch <run-id>` |
| Trigger workflow | `gh workflow run <workflow-file> --ref <branch>` |
| Download run logs | `gh run download <run-id>` |
| Cancel run | `gh run cancel <run-id>` |

---

## Releases

| Operation | Command |
|---|---|
| Create release | `gh release create <tag> --title "<title>" --notes "<notes>"` |
| List releases | `gh release list` |
| View release | `gh release view <tag>` |
| Upload asset | `gh release upload <tag> <file>` |
| Delete release | `gh release delete <tag>` |

---

## Repository

| Operation | Command |
|---|---|
| View repo | `gh repo view` |
| Clone repo | `gh repo clone <owner>/<repo>` |
| Fork repo | `gh repo fork <owner>/<repo>` |
| List repo secrets | `gh secret list` |
| Set secret | `gh secret set <name>` |
| Auth status | `gh auth status` |

---

## Destructive Operations (require ⚠ warning)

- `git reset --hard` — discards all local changes
- `git branch -D` — force deletes branch regardless of merge state
- `git push --force-with-lease` — rewrites remote history
- `gh pr close` — closes PR without merging
- `gh issue close` — closes issue
- `gh run cancel` — cancels an in-progress workflow run
- `gh release delete` — deletes a published release
