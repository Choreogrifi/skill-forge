# Mermaid Read Subflow

Reviews existing Mermaid code for syntax errors, layout issues, and improvement opportunities.

## Workflow

### 1. Locate the Diagram

Ask the user for the source:
```
Where is the Mermaid diagram?
  1. Paste it here
  2. Provide a file path

Enter 1–2:
```

Read the code. Identify the diagram type from the first line.

### 2. Validate Syntax

Check for:
- Valid diagram type declaration (must match a supported Mermaid type)
- Unclosed brackets or parentheses
- Invalid arrow syntax for the diagram type
- Node ID collisions (same ID used for different nodes)
- Subgraph nesting depth > 2

### 3. Check Layout Quality

Flag:
- More than 15 nodes in a single diagram → suggest splitting
- Labels too long to render cleanly (> 40 chars) → suggest shortening or using `<br>`
- Missing diagram title (for flowcharts and sequences)
- Mixing of concern types in one diagram (e.g., state transitions in a flowchart)

### 4. Report Findings

```
Diagram Review
──────────────
Type: <diagram type>
Nodes: <count>

Issues:
  [ERROR] <issue description> (line <N>)
  [WARN]  <improvement suggestion>

Overall: PASS / FAIL
```

If FAIL: ask the user whether to fix automatically or manually.
If fixing automatically: activate `mermaid-write-sf` with the corrected intent.

## Guidelines

- Read-only unless the user explicitly requests a fix.
- Never modify the original file without user confirmation.
