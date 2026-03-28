---
name: skill-detector
skill-type: system
memory-file: system/skill-detector.md
description: Detects new skill opportunities during a session and prompts the user to Create, Defer, or Decline. Writes a structured deferred plan stub on Defer. Operates as a background protocol defined in model.md.
disable-model-invocation: true
---

# Skill Detector

Monitors the active session for patterns that suggest a missing skill. When a gap
is identified, proposes the new skill with a one-line description and presents three
options: Create now, Defer, or Decline. Never re-proposes a declined skill within
the same session.

## Detection Triggers

Activate when any of the following conditions are met:

1. The same ad-hoc, multi-step process appears 2+ times in a session with no
   matching active skill
2. The user describes a workflow and asks the model to execute it repeatedly
3. The user references a tool or technology not covered by any active skill
4. The user explicitly asks: "is there a skill for X?" or "can you save this as a skill?"

## Proposal Format

```
Potential new skill: <name> (<type>) — <one-line description>.
Create now / Defer / Decline?
```

- `name`: lowercase, hyphen-separated (e.g., `postman-runner`, `cloud-run-deployer`)
- `type`: one of `sme-persona`, `workflow`, `system`
- Description: what the skill does, not how — max 15 words

## Response Handling

### Create now
→ Invoke `manage-skills` → Op 2 (Create skill)
→ Use the appropriate template based on type:
  - `sme-persona` → `expertise-skill-template.md`
  - `workflow` or `system` → `workflow-skill-template.md`

### Defer
→ Write a plan stub to:
  `~/.llm-assets/memory/deferred-skills/<name>-YYYY-MM-DD.md`

Stub format:
```markdown
---
skill-name: <name>
skill-type: sme-persona | workflow | system
status: deferred
deferred-on: YYYY-MM-DD
---

# Deferred Skill: <name>

## Description
<one-line description>

## Trigger Context
<one paragraph: what the user was doing when this skill was identified>

## Implementation Steps
1. Invoke manage-skills → Op 2 (Create skill)
2. Select template: expertise-skill-template or workflow-skill-template
3. Define SKILL.md content based on the trigger context above
4. Create memory stub: ~/.llm-assets/memory/<type>/<name>.md
5. Create symlink: ~/.claude/skills/<name> → ~/.llm-assets/skills/<name>.active/
6. Update SKILL.md frontmatter with skill-type and memory-file fields
```

→ Confirm the stub path to the user:
  `"Deferred plan saved: ~/.llm-assets/memory/deferred-skills/<name>-YYYY-MM-DD.md"`

### Decline
→ Acknowledge: `"Understood. Skill proposal suppressed for this session."`
→ Do not re-propose this skill for the remainder of the session
→ Do not persist the decline — it is session-scoped only

## Constraints

- Propose a maximum of one new skill per distinct pattern — do not flood the user
- Never propose a skill that already exists in `~/.llm-assets/skills/` (check first)
- The deferred plan stub is the only file written — no SKILL.md is created on Defer
- Suppression on Decline is session-scoped: the skill may be re-proposed in future sessions
  if the pattern recurs organically
