# Mermaid Output Patterns

This reference provides best practices for creating clear, readable, and well-structured Mermaid diagrams.

## 1. Pre-validation (Crucial Step)

Before writing any Mermaid code, you MUST explicitly validate the type of diagram requested against Mermaid's supported types.

**Supported Diagram Types (Common):**
*   `flowchart` (TD, LR, RL, BT)
*   `sequenceDiagram`
*   `classDiagram`
*   `stateDiagram-v2`
*   `erDiagram`
*   `gantt`
*   `pie`
*   `mindmap`
*   `timeline`

If the requested visualization doesn't clearly map to a supported type, choose the best fit (usually a `flowchart` or `sequenceDiagram`) and briefly state your choice.

## 2. Layout & Spacing Rules

**Flowcharts (`flowchart`)**
*   **Direction:** Use `TD` (Top-Down) for hierarchical data or `LR` (Left-Right) for process flows.
*   **Node Text Length:** Keep text inside nodes concise. If text is long, use line breaks `<br>` or HTML-like labels to prevent nodes from becoming unreadably wide.
*   **Spacing Links:** Use longer links (e.g., `--->` instead of `-->`) to force more vertical/horizontal space between specific nodes if they are overlapping or crowded.
*   **Subgraphs:** Use `subgraph` to group related components logically. Give subgraphs clear, brief titles.
*   **Avoid Crossing Lines:** Structure the flow to minimize crossed lines. Sometimes duplicating a minor reference node is better than a line cutting across the entire diagram.

**Sequence Diagrams (`sequenceDiagram`)**
*   **Actor/Participant Order:** Define participants explicitly at the top in the logical order they should appear (usually left-to-right).
*   **Autonumbering:** Always use `autonumber` to make complex flows easier to follow.
*   **Activations:** Use `activate` and `deactivate` (or the `+`/`-` shorthand) to show execution focus.
*   **Notes:** Use notes (`Note right of...`, `Note over...`) generously to explain complex logic that isn't obvious from the message names.
*   **Line Breaks in Messages:** If a message name or note is long, use `<br/>` to break it up.

## 3. General Best Practices

*   **Syntax Strictness:** Mermaid syntax is strict. Ensure proper spacing around arrows and consistent node ID naming (e.g., use `nodeA["My Node Text"]` instead of `My Node Text`).
*   **Semantic IDs:** Use short, semantic IDs for nodes (e.g., `db`, `auth_service`, `client`) and map them to descriptive labels.
*   **Styling (Use Sparingly):** Rely on Mermaid's default themes. Only use custom `style` or `classDef` directives if explicitly required to highlight a specific component (e.g., styling a failing node red).
*   **Testing:** Always mentally dry-run the syntax before finalizing to ensure it will compile correctly without parse errors.
