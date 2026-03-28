---
name: write-readme
skill-type: workflow
memory-file: workflow/write-readme.md
description: Drafts a production-quality, SEO-optimised Git README.md following the 2026 best-layout standard. Confirms file location with the user before writing. Activated by document-writer or invoke directly for any README creation task.
disable-model-invocation: true
---

# Write README

Generates a complete, discoverable `README.md` using the 2026 standard layout. Gathers project details interactively, drafts the full document, confirms the target path, and writes the file only on approval.

## Workflow

### 1. Gather Project Details

Collect the following fields. If called from `document-writer`, the subject is already known — skip that question and ask only for what is missing:

```
Project name:
One-line description (what it does and who it's for):
Primary language / runtime:
Key features (up to 5, one per line):
Tech stack (frameworks, databases, cloud services):
Installation steps (brief — how to get it running locally):
Primary usage example:
License (MIT / Apache-2.0 / GPL-3.0 / proprietary / other):
Badge integrations available? (CI, coverage, npm/pypi version — yes/no):
```

Ask all questions in a single prompt block. Accept partial answers — missing fields are left as template placeholders.

### 2. Confirm Target Location

```
Where should README.md be saved?
Default: ./README.md
(Press Enter to accept or type a different path)
```

Wait for explicit confirmation before proceeding to Step 3.

### 3. Draft README

Read `references/readme-template.md` and populate it with the collected details.

Rules:
- Replace every `<!-- placeholder -->` with real content where data was provided.
- Leave unfilled placeholders as `> TODO: <description>` so the user knows what to add later.
- Populate the badges row only with badges the user confirmed are available.
- Keep the Quick Start to 5 commands or fewer.
- Write the description paragraph with searchable keywords naturally embedded.
- Do not invent features, stack items, or configuration that were not provided.

Present the full draft in a code block for review:

```
README.md draft
───────────────
<full markdown content>
───────────────
Does this look correct? (yes / edit / cancel)
```

### 4. Revise (if edit selected)

Ask: `What would you like to change?` Apply changes and return to Step 3.

### 5. Write File

On `yes`, write the file to the confirmed path. Confirm:

```
Written: <path>
```

## Guidelines

- **Keywords matter:** The description, features, and tech stack sections must use natural, searchable language — the project should surface in GitHub/GitLab search, Google, and `awesome-*` lists.
- **No invented content:** Only write what the user provided. Placeholders are preferable to inaccurate content.
- **Badges are optional:** Do not add badge markup for integrations the user has not confirmed exist.
- **Template is the contract:** The 2026 layout in `references/readme-template.md` is the required structure — do not skip sections or reorder them.

## References

- `references/readme-template.md` — 2026 README layout with all sections and placeholder markup; read during Step 3
