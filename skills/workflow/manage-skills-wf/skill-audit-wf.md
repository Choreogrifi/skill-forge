# Skill Audit Workflow

Audits skill content quality — frontmatter correctness, lean structure, and memory
file health. Symlink and state invariant issues are delegated to the `agents` CLI.

## Workflow

### 1. Discover Skills

Use Glob with pattern `~/.llm-assets/skills/*/SKILL.md`. For each result path
`.../skills/<name>.<state>/SKILL.md`, extract `name` and `state` by splitting the
parent directory name on the last `.`.

### 2. Run Checks

Read each `SKILL.md` and collect all failures before reporting. Run every check
regardless of earlier failures.

**Naming convention checks:**
- Directory base name (before the last `.`) does not end with `-sme` or `-wf` → `NAMING VIOLATION: expected <base>-sme or <base>-wf`

**Frontmatter checks:**
- `name` field value does not match directory's `<name>` component → `NAME MISMATCH`
- `description` field is absent or empty → `MISSING DESCRIPTION`
- `disable-model-invocation: true` absent → `MISSING DMI FLAG`
- `skill-type` field is absent → `MISSING SKILL-TYPE`
- `memory-file` field is absent → `MISSING MEMORY-FILE` (warn — optional but expected)

**Lean checks:**
- Any contiguous block of non-heading, non-code prose exceeds 10 lines → `BLOATED SECTION` (flag the heading)
- Long lists, lookup tables, or embedded specs present with no `## References` section → `MISSING REFERENCES SECTION`

**Memory checks:**
- For each skill with a `memory-file` field: check `~/.llm-assets/memory/<memory-file>` exists → if not → `MISSING MEMORY FILE`
- For each `.md` file under `~/.llm-assets/memory/` (exclude `deferred-skills/` and `*.archived.md`): verify at least one active skill's `memory-file` references it → if not → `ORPHANED MEMORY FILE`
- For each memory file: check `last-updated` frontmatter field — if older than 90 days → `STALE MEMORY FILE`

**Deferred skill checks:**
- Use Glob `~/.llm-assets/memory/deferred-skills/*.md`
- For each, read the `deferred-on` frontmatter field
- If older than 30 days → `DEFERRED SKILL OVERDUE: <skill-name>`

### 3. Delegate Symlink Issues

Do not attempt to fix symlinks or rename directories. After presenting the report:

```
For symlink and state violations, run: agents audit
```

### 4. Report

Present a full summary table:

```
Skill           | Check                        | Status
--------------- | ---------------------------- | ------
```

Flag content and memory issues for manual review. Do not auto-edit skill bodies
or memory files.

## Guidelines

- Read-only — this workflow never writes files.
- Symlink invariant enforcement belongs exclusively to `agents audit`.
- Surface deferred skill reminders as informational — do not block the report on them.
