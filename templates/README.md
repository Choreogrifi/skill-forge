# Templates

Templates are the starting point for creating new skills, memory files, and reference documents. Copy a template, fill in the placeholders, and you have a working file.

---

## Available templates

| Template | Use it to create |
|---|---|
| `sme/{sme-name}-sme.md` | A new SME skill `SKILL.md` |
| `workflow/subflow-skill.md` | A new workflow skill `SKILL.md` |
| `workflow/{sme-name}-wf.md` | A subflow content file (no frontmatter, lives in `subflows/`) |
| `subflow/{sme-name}-{action}-sf.md` | A subflow content file (alternative template with examples) |
| `memory/sme-memory.md` | A memory file for an SME skill |
| `memory/workflow-memory.md` | A memory file for a workflow skill |
| `persona/system-skills-always-on.md` | System skills block for always-on mode (appended to model.md) |
| `persona/system-skills-manual.md` | System skills block for manual mode (appended to model.md) |
| `reference/{reference-name}-ref.md` | A reference document (static, lazy-loaded) |
| `persona/model.md` | Your personal AI persona file (local use only, never committed) |

---

## How to use a template

1. Copy the template to the correct location:
   ```bash
   cp templates/sme/{sme-name}-sme.md skills/sme/<your-skill>-sme/SKILL.md
   ```

2. Open the file and replace every `<PLACEHOLDER>` with real content.

3. Delete any comment blocks (`<!-- ... -->`) that were guides for filling in the file.

4. Validate the result:
   ```bash
   skillforge audit
   ```

---

## Template rules

All templates must:
- Use `<angle-bracket>` placeholders for values the user fills in
- Use `<!-- comment -->` blocks to explain each section
- Stay under 50 lines including comments
- Match the schema of real files (frontmatter uses `metadata:` block)

**Name field rule:** the `name:` field in `SKILL.md` must equal the directory name exactly — e.g. `name: my-skill-sme`. It never includes a state suffix. State is encoded by directory location, not by name.

---

## Persona template

`templates/persona/model.md` is special — it is a template for your **personal** AI persona file. This file is **never committed to Git**. After filling it in, save it to `~/.skillforge/persona/model.md`. The install script creates a symlink from your LLM's context file to this location.
