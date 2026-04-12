# .memory

Project memory for Claude Code. Contains preferences, feedback, and context
that persist across sessions and machines.

## On a New Machine

After cloning the repo, copy this folder to the Claude projects memory location:

```bash
REPO_PATH="$HOME/development/skill-forge"
MEMORY_DEST="$HOME/.claude/projects/$(echo $REPO_PATH | sed 's|/|-|g' | sed 's|^-||')/memory"
mkdir -p "$MEMORY_DEST"
cp "$REPO_PATH/.memory/"*.md "$MEMORY_DEST/"
```

Claude Code will load these automatically on the next session in this project.

## Files

| File | Type | Summary |
|---|---|---|
| `feedback_pr_workflow.md` | feedback | All changes via PR — no direct commits to main |
