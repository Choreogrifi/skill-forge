# Mermaid Write Subflow

Generates a new Mermaid diagram from a user description or intent.

## Workflow

### 1. Identify Diagram Type

Ask the user what they want to visualise if not already clear:

```
What type of diagram do you need?

  1. Flowchart — process steps, decisions, branching logic
  2. Sequence — interactions between components or actors over time
  3. State — lifecycle states and transitions
  4. ER / Class — data model or object structure
  5. C4 Context — high-level system and actor boundaries
  6. Other — describe it

Enter 1–6:
```

Confirm the selection before proceeding.

### 2. Read Output Patterns

Read `references/output-patterns.md` to load the validated layout, spacing, and
syntax rules for the selected diagram type. Apply them strictly throughout generation.

### 3. Generate Code

Produce the Mermaid code block. Enforce:
- Diagram type declaration on the first line (e.g. `flowchart TD`, `sequenceDiagram`)
- No overlapping labels; use `<br>` for multi-line node text
- Subgraphs used logically — no more than 2 levels of nesting
- Node count ≤ 15 per diagram; split if larger

Output:
```mermaid
<generated diagram code>
```

### 4. Confirm with User

```
Does this diagram look correct?
  1. Accept
  2. Edit — describe what to change
  3. Discard

Enter 1–3:
```

On edit: apply the change and return to this step.

## Guidelines

- Output only the Mermaid code block. Do not over-explain.
- If the intent is ambiguous, ask one clarifying question before generating.
