---
name: manage-skills
skill-type: system
memory-file: system/manage-skills.md
description: Manage the full lifecycle of custom skills — list, create, activate, review, deactivate, decommission, and audit. Invoke when you want to create a new skill, change a skill's state, or audit the skill registry.
disable-model-invocation: true
---

# Manage Skills

Manages custom skills stored in `/Users/leond/.llm-assets/skills/`. State is encoded in the directory name — no metadata field required.

## Paths

| Resource | Path |
|---|---|
| Skill source | `/Users/leond/.llm-assets/skills/<name>.<state>/` |
| Claude symlinks | `/Users/leond/.claude/skills/<name>` → source (active only) |
| Gemini symlinks | `/Users/leond/.gemini/skills/<name>` → source (active only) |
| Templates | `/Users/leond/.llm-assets/skills/manage-skills.active/templates/` |
| Memory root | `/Users/leond/.llm-assets/memory/` |
| Deferred skill plans | `/Users/leond/.llm-assets/memory/deferred-skills/` |
| Marketplace overlap | `/Users/leond/.llm-assets/skills/manage-skills.active/references/marketplace-overlap.md` |
| Global skills (audit-only) | `~/.agents/skills/` — out of scope for all operations except Op 7 symlink management |

> **Tool note:** Use **Glob** for all directory listing — it works with absolute paths. Use pattern `*/SKILL.md` (not `*/`) to match skill directories reliably; extract the directory name from each matched path. Use Bash only for mutations (`mv`, `ln -s`, `rm`). Use Read only for file contents.

## State Model

State is the suffix of the skill directory name. `ls /Users/leond/.llm-assets/skills/` shows all skills and their states at a glance.

| State | Directory name | Claude symlink | Gemini symlink |
|---|---|---|---|
| **active** | `<name>.active` | yes | yes |
| **review** | `<name>.review` | no | no |
| **deactivated** | `<name>.deactivated` | no | no |
| **decommissioned** | `<name>.decommissioned` | no | no |

All skills carry `disable-model-invocation: true`. No other flags are needed — symlinks are the sole visibility control. Transitions rename the directory and reconcile symlinks in both `/Users/leond/.claude/skills/` and `/Users/leond/.gemini/skills/`.

### State detection

Use Glob with pattern `/Users/leond/.llm-assets/skills/*/SKILL.md`. Each result path has the form `.../skills/<name>.<state>/SKILL.md` — extract `<name>` and `<state>` from the parent directory name (split on last `.`).

## Operations Menu

When invoked without a specific request only present the menu for further actions:

```
Skill Manager — what would you like to do?

  1. List skills          — show all skills and their states
  2. Create skill         — scaffold a new skill from a template (guided)
  3. Activate skill       — create symlinks, rename to .active
  4. Put skill in review  — remove symlinks, rename to .review
  5. Deactivate skill     — remove symlinks, rename to .deactivated
  6. Decommission skill   — permanently retire (rename to .decommissioned)
  7. Audit               — find and fix inconsistencies (symlinks, frontmatter, memory, deferred plans)
  8. Marketplace overlap  — show which plugins conflict with custom skills
  9. Memory              — manage skill memory files (create stub, list, view, audit, archive)

Enter a number, 0 to return to the main menu, or C to cancel and deactivate:
```

## Operation 1 — List Skills

1. Use Glob with pattern `/Users/leond/.llm-assets/skills/*/SKILL.md` to find all skills.
2. For each result path `.../skills/<name>.<state>/SKILL.md`, extract `name` and `state` by splitting the parent directory name on the last `.`.

Present a table sorted by state:

```
State            | Skill
---------------- | -----
```

## Operation 2 — Create Skill (Guided)

**Interactive — collect each field before proceeding.**

### Step 1 — Skill name

```
Skill name (lowercase, hyphen-separated, e.g. "api-reviewer"):
```

Validate: matches `^[a-z][a-z0-9-]+$` and no directory `/Users/leond/.llm-assets/skills/<name>.*` already exists.

### Step 2 — Select template type

```
What type of skill do you want to create?

  1. Expertise   — domain knowledge and standards (e.g. architect, security, tester)
  2. Workflow    — step-by-step automation with confirmation gates (e.g. git-commit)

Enter 1 or 2 or 0 to return to the main menu:
```

Load template:
- `1` → `templates/expertise-skill-template.md`
- `2` → `templates/workflow-skill-template.md`

### Step 3 — Description

```
One-line description (what it does and when to invoke it):
```

### Step 4 — Body fields

**Expertise**: Focus area → Standards (one per line) → Mandatory tasks (one per line) → Constraints (one per line).

**Workflow**: Problem it solves → Step names (one per line) → Additional guidelines (one per line).

After collecting body fields, ask:

```
Does this skill need any reference files (lookup tables, specs, long lists)?
If yes, describe each one — they will be written to references/<name>.md
and linked lazily instead of inlined. (yes / no)
```

If yes: collect a name and content for each reference file. Write each to `references/<name>.md` inside the skill directory. Add a `## References` section to `SKILL.md` listing each file and the step/condition that triggers loading it.

> **Rule:** Any content longer than ~10 lines that is only needed for a specific step belongs in a reference file, not inline in `SKILL.md`.

### Step 5 — Preview and confirm

Display generated `SKILL.md` and ask: `Does this look correct? (yes / edit / cancel)`

### Step 6 — Write

All files must be written to `/Users/leond/.llm-assets/skills/` — never to the current working directory.

1. Create `/Users/leond/.llm-assets/skills/<name>.active/`
2. Write `SKILL.md` inside that directory.
3. If reference files were collected in Step 4, write each to `<name>.active/references/<file>.md`.
4. Check `references/marketplace-overlap.md` and warn on any conflict.
5. Run **create-symlinks** to make the skill visible to all agents.
6. Offer to create a memory stub via Op 9a:
   ```
   Create a memory stub for this skill at ~/.llm-assets/memory/<group>/<name>.md? (yes / no)
   ```
7. Confirm:
   ```
   Created: /Users/leond/.llm-assets/skills/<name>.active
   Reference files: <list or "none">
   Memory stub: <path or "skipped">
   Symlinks: created in Claude + Gemini
   ```

## Skill Picker

Apply this procedure whenever an operation needs a target skill:

1. If the user's input is `<number>, <name>` or `<number>; <name>`, use Glob with `/Users/leond/.llm-assets/skills/<name>.*/SKILL.md` to find that specific skill. If not found, fall back to step 2.
2. Otherwise, use Glob with `/Users/leond/.llm-assets/skills/*/SKILL.md`, filter to the eligible states for the operation, and present a numbered list. Wait for the user's selection.
3. Extract `<name>` and `<state>` from the matched path's parent directory name (split on last `.`). If `state == decommissioned` → refuse.

## Shell Procedures

Reusable commands referenced by operations 3–6.

**create-symlinks**
```bash
ln -s /Users/leond/.llm-assets/skills/<name>.active /Users/leond/.claude/skills/<name>
ln -s /Users/leond/.llm-assets/skills/<name>.active /Users/leond/.gemini/skills/<name>
```

**remove-symlinks**
```bash
rm -f /Users/leond/.claude/skills/<name>
rm -f /Users/leond/.gemini/skills/<name>
```

**rename-dir `<target>`**
```bash
mv /Users/leond/.llm-assets/skills/<name>.<state> /Users/leond/.llm-assets/skills/<name>.<target>
```

## Operation 3 — Activate Skill

Use Skill Picker (eligible: non-active).

1. Run **rename-dir** `active`.
2. Run **create-symlinks**.
3. Check `references/marketplace-overlap.md` — warn if a conflicting plugin is installed.
4. Report: `<name>.<state>` → `<name>.active`, symlinks created in Claude + Gemini.

## Operation 4 — Put Skill in Review

Use Skill Picker (eligible: non-review, non-decommissioned).

1. Run **remove-symlinks**.
2. Run **rename-dir** `review`.
3. Report: `<name>.<state>` → `<name>.review`, symlinks removed, invisible to all agents.

## Operation 5 — Deactivate Skill

Use Skill Picker (eligible: non-deactivated, non-decommissioned).

1. Run **remove-symlinks**.
2. Run **rename-dir** `deactivated`.
3. Report: `<name>.<state>` → `<name>.deactivated`, symlinks removed.

## Operation 6 — Decommission Skill

Use Skill Picker (eligible: non-decommissioned).

Warn:
```
Decommissioning is permanent and cannot be undone. Proceed? (yes / cancel)
```

1. Run **remove-symlinks**.
2. Run **rename-dir** `decommissioned`.
3. Report: `<name>.<state>` → `<name>.decommissioned`. Terminal — suggest creating a new skill if capability needed again.

## Operation 7 — Audit

1. Use Glob with `/Users/leond/.llm-assets/skills/*/SKILL.md` to find all skills; extract `name` and `state` from each parent directory name.
2. Use Glob with `/Users/leond/.claude/skills/*` to get the Claude symlink names.
3. Use Glob with `/Users/leond/.gemini/skills/*` to get the Gemini symlink names.
4. For each skill, Read its `SKILL.md` and run all checks below. Collect every failure before reporting.

**Symlink checks** (no file read needed — use directory name + symlink lists):
- `state == active` and name absent from Claude or Gemini symlink list → `MISSING SYMLINK`
- `state != active` and name present in either symlink list → `STALE SYMLINK`
- Name in Claude or Gemini symlink list but no matching `<name>.*` skill directory → `BROKEN SYMLINK`

**Global skills check** (`~/.agents/skills/` — symlink management only, no rename/decommission):
- Use Bash `ls ~/.agents/skills/` to list all global skill names.
- For each global skill: absent from Claude or Gemini symlink list → `MISSING GLOBAL SYMLINK` (auto-fix by creating symlinks pointing to `~/.agents/skills/<name>`).
- Any name in Claude or Gemini symlink lists that resolves to `~/.agents/skills/<name>` but that directory no longer exists → `STALE GLOBAL SYMLINK` (flag for manual removal only).
- Offer to fix all missing global symlinks automatically alongside local symlink fixes.

**Frontmatter checks** (require reading the file):
- `disable-model-invocation: true` absent → `MISSING DMI FLAG`
- `name` field value does not match the directory's `<name>` component → `NAME MISMATCH`
- `description` field is absent or empty → `MISSING DESCRIPTION`
- `skill-type` field is absent → `MISSING SKILL-TYPE` (treat as `review`)
- `memory-file` field is absent → `MISSING MEMORY-FILE` (warn — memory is optional but expected)

**Lean checks** (require reading the file):
- Any contiguous block of non-heading, non-code prose exceeds 10 lines → `BLOATED SECTION` (flag the section heading)
- Content present that belongs in a reference file (long lists, lookup tables, embedded specs) and no `## References` section exists → `MISSING REFERENCES SECTION`

**Memory checks** (run after frontmatter checks):
- For each skill with a `memory-file` field: check that `~/.llm-assets/memory/<memory-file>` exists → if not → `MISSING MEMORY FILE` (error)
- For each `.md` file found under `~/.llm-assets/memory/` (excluding `deferred-skills/`): verify that at least one active skill's `memory-file` references it → if not → `ORPHANED MEMORY FILE` (warn)
- For each memory file found: check `last-updated` in frontmatter — if older than 90 days → `STALE MEMORY FILE` (info)

**Deferred skill checks**:
- Use Glob `~/.llm-assets/memory/deferred-skills/*.md` to find all deferred plans
- For each, read the `deferred-on` frontmatter field
- If `deferred-on` is more than 30 days ago → `DEFERRED SKILL OVERDUE: <skill-name>` (info — surface as a reminder)

5. Offer to fix all symlink issues automatically. Flag content and memory issues for manual review — do not auto-edit skill bodies or memory files.

Report a full summary table:

```
Skill           | Check                       | Status
--------------- | --------------------------- | ------
```

## Operation 9 — Memory Management

```
Memory Operations — what would you like to do?

  a. Create stub   — scaffold a blank memory file for a skill
  b. List          — show all memory files and which skills reference them
  c. View          — display the contents of a memory file
  d. Audit         — find missing, orphaned, and stale memory files
  e. Archive       — rename a memory file to <name>.archived.md

Enter a, b, c, d, or e, or 0 to return to the main menu:
```

### Op 9a — Create Memory Stub

1. Use Skill Picker to select the target skill.
2. Determine the group from its `skill-type` frontmatter: `sme-persona` → `sme/`, `workflow` → `workflow/`, `system` → `system/`.
3. Scaffold at `~/.llm-assets/memory/<group>/<skill-name>.md`:

```markdown
---
skill: <skill-name>
skill-type: <skill-type>
description: <one-line — what context this file provides>
last-updated: YYYY-MM-DD
---

<!-- Add bullet-point facts below. Max 40 lines. -->
```

4. Update the skill's `SKILL.md` frontmatter to add `memory-file: <group>/<skill-name>.md` if absent.
5. Confirm the created path.

### Op 9b — List Memory Files

1. Use Glob `~/.llm-assets/memory/**/*.md` — exclude `deferred-skills/` and `*.archived.md`.
2. For each file, read frontmatter only (first block between `---` delimiters).
3. Present a table:

```
Type            | Group         | File                              | Skill(s)
--------------- | ------------- | --------------------------------- | --------
```

### Op 9c — View Memory File

1. Ask: `Which memory file? (enter path relative to ~/.llm-assets/memory/ or skill name)`
2. Read and display the full file.

### Op 9d — Audit Memory

Run the same memory checks as Op 7 but scoped to memory only. Present results in the same table format.

### Op 9e — Archive Memory File

Use when deactivating or decommissioning a skill (also triggered automatically by Op 5 and Op 6):

1. Identify memory files associated with the skill (via `memory-file` frontmatter).
2. Prompt: `Archive memory file <path>? (yes / no)`
3. On yes: rename `<name>.md` → `<name>.archived.md`
4. On Op 3 (Activate): check for `<skill-name>.archived.md` in the group directory.
   If found: `Archived memory file found for <skill-name>. Restore it? (yes / no)`

## Operation 8 — Marketplace Overlap

Display `references/marketplace-overlap.md`. Cross-reference against `/Users/leond/.claude/plugins/installed_plugins.json` and highlight any conflicting plugin currently installed.

## Guidelines

- **Simplicity is the top priority** — always use reusable components when creating or maintaining skills. Repeated shell commands, selection logic, and navigation belong in shared procedures, not duplicated inline. This keeps skill files concise for efficient context and memory use.
- **Always write to the skills directory** — new skills are always created under `/Users/leond/.llm-assets/skills/`. Never write skill files to the current working directory or any other location.
- **Write files only** — creating a skill means writing `SKILL.md` (and any reference files) and creating symlinks. Never zip, archive, package, or run any installation commands.
- **Keep skills lean** — `SKILL.md` must contain only invocation logic and step definitions. Never inline lookup tables, long lists, API specs, or documentation. Move that content into `references/<name>.md` files and link to them. A lean skill loads fast and uses less context budget on every invocation.
- **Lazy-load reference files** — add a `## References` section listing each file and the step or condition that needs it. Read the file only at that point, not upfront. Example: `references/style-guide.md` — read only during the review step. This avoids loading data that the current operation may never reach.
- **Navigation is universal** — `0` returns to the main menu; `C` cancels the current operation and deactivates the skill. Every prompt must honour both.
- **`/Users/leond/.llm-assets/skills/` is the source of truth** — state is the directory name suffix.
- **Never delete skill directories** — rename to `.decommissioned` instead.
- **Symlinks are the sole visibility control** — no flags needed beyond `disable-model-invocation: true`.
- **Always present a summary** after every operation.

## References

- `references/marketplace-overlap.md` — plugin conflict data; read during Op 3 (activate) and Op 8 only
- `references/mcp-playbook.md` — MCP server setup and Mac mini migration roadmap; read only when user asks about MCP infrastructure or setting up skill-supporting tools
