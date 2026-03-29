# Git Tag Subflow

Handles creating, pushing, listing, and deleting git tags.
Annotated tags are preferred over lightweight tags for releases.

## Workflow

### 1. Identify Operation

```
Tag operation:
  1. Create an annotated tag (recommended for releases)
  2. Create a lightweight tag
  3. List all tags
  4. Delete a local tag
  5. Delete a remote tag
  6. Push tags to remote

Enter 1–6:
```

### 2. Gather Details per Operation

**Create annotated:**
- Tag name (e.g. `v1.2.3`)
- Target commit (default: HEAD)
- Tag message

**Create lightweight:**
- Tag name
- Target commit (default: HEAD)

**Delete local:** tag name

**Delete remote:**
- Tag name
- Warn: deleting a remote tag may break other users who have fetched it

**Push:**
- Push all tags or a specific tag name

### 3. Propose Commands

Present a dry-run summary for approval.
For remote deletions, prepend:
```
⚠ Deleting a remote tag is irreversible and may affect other users.
```

```
Proposed actions:
─────────────────
1. <command>

Proceed? (yes / edit / cancel)
```

### 4. Execute on Approval

Run the command. Print output. Confirm with:
```
Done. Tag <name> <created / deleted / pushed>.
```

## Guidelines

- **Prefer annotated tags** for any version or release tag — they carry a message and tagger identity.
- **Semantic versioning:** suggest `vMAJOR.MINOR.PATCH` format for release tags.
- Never force-push a tag that has already been pushed to a shared remote without explicit justification.
