# GitHub Release Subflow

Handles drafting GitHub releases, attaching artefacts, and publishing using the `gh` CLI.
All operations require explicit user approval before execution.

## Workflow

### 1. Gather Release Details

Ask the user:

```
Release details:
  Tag name (e.g. v1.2.3):
  Target branch or commit (default: main):
  Release title:
  Release notes (describe / generate from commits / manual):
  Draft? (yes — save without publishing / no — publish immediately):
  Pre-release? (yes / no):
  Artefacts to attach? (file paths, space-separated, or none):
```

If the user says "generate from commits", run:
```
gh api repos/<owner>/<repo>/releases/generate-notes \
  --method POST -f tag_name=<tag> -f target_commitish=<branch>
```
and present the generated notes for editing.

### 2. Propose Command

```
Proposed actions:
─────────────────
1. gh release create <tag> \
     --title "<title>" \
     --notes "<notes>" \
     [--draft] [--prerelease] \
     [artefact-paths...]

Proceed? (yes / edit / cancel)
```

### 3. Execute on Approval

Run the command. Print the release URL on success.
If artefact upload fails: report which files failed and offer to retry.

### 4. Post-Release

Ask: `Would you like to edit the release in the browser?`
If yes: `gh release view <tag> --web`

## Guidelines

- Always confirm the tag exists locally before creating a release: `git tag -l <tag>`
- If the tag does not exist, offer to create it via the manage-git-tag-sf subflow first.
- Never publish a release (non-draft) without the user explicitly confirming the tag and notes.
- For artefacts, verify each file exists before proposing the command.
