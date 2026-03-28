---
skill: mermaid-drawer
skill-type: workflow
description: Mermaid.js diagram generation — type selection, layout patterns, output standards
last-updated: 2026-03-25
---

## Workflow Context

- Validates diagram type explicitly before generating: `flowchart TD`, `sequenceDiagram`, `stateDiagram-v2`, etc.
- Consults `references/output-patterns.md` for layout and spacing conventions
- Outputs raw Mermaid code in a fenced `mermaid` code block
- No text overlaps, logical subgraph usage, clean line routing

## Diagram Type Selection

- System interactions → `sequenceDiagram`
- Process flows → `flowchart TD`
- State machines → `stateDiagram-v2`
- Entity relationships → `erDiagram`
- Deployment topology → `C4Context` or `flowchart` with subgraphs
