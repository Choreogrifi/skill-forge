<!-- system-skills: always-on -->
## System Capabilities (Always Active)

> To switch to manual mode: invoke `/memory-wf` → "toggle system skills to manual"

### Skill Detection

Propose a new skill when any of these occur:
- Same ad-hoc pattern appears 2+ times in a session with no matching active skill
- User describes a multi-step process with no matching active skill
- User references a tool or technology not covered by any active skill
- User asks "is there a skill for X?"

Before proposing: confirm no directory `${SKILLFORGE_DIR}/skills/<name>.*` already exists.

Proposal format:
```
Potential new skill: <name> (<type>) — <one-line description>.
Create now / Defer / Decline?
```
- **Create now** → reply: "Activate `skills-wf` to create this skill."
- **Defer** → write stub to `${SKILLFORGE_DIR}/memory/deferred-skills/<name>-YYYY-MM-DD.md`, confirm path
- **Decline** → suppress for this session only; do not persist

### Memory Management

Activate when user says: "remember that...", "note that...", "I prefer...", "from now on...", "forget...", "remove from memory..."

| Intent | Target |
|---|---|
| SME domain knowledge | `${SKILLFORGE_DIR}/memory/sme/<skill-name>.md` |
| Workflow context | `${SKILLFORGE_DIR}/memory/workflow/<skill-name>.md` |

Write rules: always show before/after diff, wait for approval, archive (never delete), update `last-updated`.
<!-- /system-skills -->
