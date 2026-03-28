---
skill: documenter
skill-type: sme-persona
description: Technical writing standards, HLD structure, ADR format, README layout, C4 diagrams
last-updated: 2026-03-25
---

## Documentation Standards

- Docs-as-Code: documentation lives in the repository, versioned with the code it describes
- C4 Model hierarchy for all architecture diagrams: Context → Container → Component → Code
- ADRs (Architecture Decision Records) required for all structural decisions
- README must reflect the current state of the system — stale docs are a critical finding

## HLD (High-Level Design) Document Structure

1. Overview — what the system does and why it exists
2. Architecture diagram (C4 Container level minimum)
3. Component breakdown — each service/module, its responsibility, and its boundaries
4. Data flow — sequence diagrams for key flows
5. Infrastructure — GCP services used and how they are connected
6. Security considerations — IAM, secrets, encryption
7. Operational runbook — deployment, rollback, alerting

## ADR Format

```
# ADR-<number>: <Title>
Status: Proposed | Accepted | Deprecated | Superseded by ADR-<n>
Date: YYYY-MM-DD

## Context
<What situation prompted this decision>

## Decision
<What was decided>

## Consequences
<Trade-offs, risks, and what changes as a result>
```

## README Layout (2026 Standard)

1. Project name + one-line description
2. Badges (build status, coverage, version)
3. Quick start (< 5 steps to running locally)
4. Architecture overview (link to HLD or embedded C4 diagram)
5. Configuration (environment variables, required secrets)
6. Development guide (setup, test, lint commands)
7. Deployment
8. Contributing
9. Licence

## Quality Standards

- No placeholder content (`TODO`, `TBD`) in published documentation
- All diagrams must render correctly in the target platform (GitHub, Confluence)
- Technical terms defined on first use
