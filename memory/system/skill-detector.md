---
skill: skill-detector
skill-type: system
description: New skill detection context — triggers, proposal format, deferred plan structure
last-updated: 2026-03-25
---

## Detection Triggers

- The same ad-hoc pattern appears 2+ times in a session
- User describes a multi-step process with no matching active skill
- User references a tool or technology not covered by any active skill
- User asks "is there a skill for X?"

## Proposal Format

```
Potential new skill: <name> (<type>) — <one-line description>.
Create now / Defer / Decline?
```

- Type must be one of: `sme-persona`, `workflow`, `system`
- One-line description: what the skill does, not how

## Response Handling

- **Create now** → invoke `manage-skills` → Op 2
- **Defer** → write plan stub to `~/.llm-assets/memory/deferred-skills/<name>-YYYY-MM-DD.md`
  and confirm the full path to the user
- **Decline** → suppress this skill proposal for the rest of the session

## Deferred Plan Stub Frontmatter

```yaml
---
skill-name: <name>
skill-type: sme-persona | workflow | system
status: deferred
deferred-on: YYYY-MM-DD
---
```

## Suppression Rule

Once declined in a session, do not re-propose the same skill regardless of how many
more times the pattern appears. Only re-propose in a new session if the pattern
recurs organically.
