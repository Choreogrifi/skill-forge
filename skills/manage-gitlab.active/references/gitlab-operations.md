# GitLab Operations Reference

Command syntax for local git and GitLab platform operations via `git` and `glab` CLIs.

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

## Merge Requests

| Operation | Command |
|---|---|
| Create MR | `glab mr create --title "<title>" --description "<desc>" --target-branch <base>` |
| Create MR (draft) | `glab mr create --draft --title "<title>" --description "<desc>" --target-branch <base>` |
| List open MRs | `glab mr list` |
| View MR | `glab mr view <number>` |
| View MR (browser) | `glab mr view <number> --web` |
| Checkout MR branch | `glab mr checkout <number>` |
| Merge MR | `glab mr merge <number>` |
| Merge MR (squash) | `glab mr merge <number> --squash` |
| Merge MR (rebase) | `glab mr merge <number> --rebase` |
| Close MR | `glab mr close <number>` |
| Approve MR | `glab mr approve <number>` |
| Revoke approval | `glab mr revoke <number>` |
| Add comment | `glab mr note <number> --message "<comment>"` |
| List MR changes | `glab mr diff <number>` |
| Add reviewer | `glab mr update <number> --reviewer <username>` |
| Add label | `glab mr update <number> --label "<label>"` |

---

## Issues

| Operation | Command |
|---|---|
| Create issue | `glab issue create --title "<title>" --description "<desc>"` |
| List issues | `glab issue list` |
| View issue | `glab issue view <number>` |
| Close issue | `glab issue close <number>` |
| Reopen issue | `glab issue reopen <number>` |
| Add comment | `glab issue note <number> --message "<comment>"` |
| Assign issue | `glab issue update <number> --assignee <username>` |
| Add label | `glab issue update <number> --label "<label>"` |

---

## Pipelines & CI/CD

| Operation | Command |
|---|---|
| List pipelines | `glab pipeline list` |
| View pipeline | `glab pipeline view <id>` |
| Trigger pipeline | `glab pipeline run --branch <branch>` |
| Cancel pipeline | `glab pipeline cancel <id>` |
| Retry pipeline | `glab pipeline retry <id>` |
| List pipeline jobs | `glab pipeline ci view` |
| View job log | `glab pipeline ci trace <job-id>` |
| List CI variables | `glab variable list` |
| Set CI variable | `glab variable set <key> --value "<value>"` |

---

## Releases

| Operation | Command |
|---|---|
| Create release | `glab release create <tag> --name "<title>" --notes "<notes>"` |
| List releases | `glab release list` |
| View release | `glab release view <tag>` |
| Upload asset | `glab release upload <tag> <file>` |
| Delete release | `glab release delete <tag>` |

---

## Repository

| Operation | Command |
|---|---|
| View repo | `glab repo view` |
| Clone repo | `glab repo clone <namespace>/<repo>` |
| Fork repo | `glab repo fork <namespace>/<repo>` |
| List repo members | `glab member list` |
| Auth status | `glab auth status` |

---

## Destructive Operations (require ⚠ warning)

- `git reset --hard` — discards all local changes
- `git branch -D` — force deletes branch regardless of merge state
- `git push --force-with-lease` — rewrites remote history
- `glab mr close` — closes MR without merging
- `glab issue close` — closes issue
- `glab pipeline cancel` — cancels a running pipeline
- `glab release delete` — deletes a published release
- `glab variable set` — overwrites an existing CI/CD variable
