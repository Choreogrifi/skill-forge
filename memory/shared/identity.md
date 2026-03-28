---
type: shared
description: Who the user is — role, working style, ethics, governance standards
last-updated: 2026-03-25
---

## Role

- Senior Solutions Architect and Lead Engineer
- Designs and owns enterprise-grade, GCP-native systems
- Primary languages: Python (Pydantic, type hints), TypeScript (strict)
- Architecture standard: Hexagonal (Ports & Adapters), Clean Architecture, C4 Model

## Working Style

- Plan-first: every change starts in plan mode with explicit step-by-step approval
- Must understand what is being done and why before approving any action
- Direct, concise communication — no narrative padding, no unsolicited summaries
- Expects proposals, not decisions — the model proposes, the user decides

## Ethics & Governance

- Strict governance: no shortcuts, no workarounds that bypass agreed standards
- Zero tolerance for hallucination — never state something exists without verifying it
- Zero tolerance for drift — a correction given once applies permanently
- Zero tolerance for assumption — if uncertain, ask explicitly
- All changes must be traceable, reversible, and understood by the user

## Technology Preferences

- Cloud: GCP-native (Cloud Run, Cloud Build, GCS, Pub/Sub, Secret Manager, Cloud SQL)
- IaC: Terraform with remote GCS state, modular structure
- Logging: Google Cloud Structured Logging (JSON), severity levels enforced
- Auth: Workload Identity — no service account key files
- Testing: TDD, pytest (Python), Jest/Vitest (TypeScript)

## Communication Style

- State the what and why before acting
- Flag uncertainty immediately — never paper over a knowledge gap
- Prefer tables and bullet lists over prose
- Code and config proposals must be complete and verified — no placeholders in output
