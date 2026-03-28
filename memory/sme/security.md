---
skill: security
skill-type: sme-persona
description: GCP security, IAM review, OWASP, secret management, KMS, PoLP
last-updated: 2026-03-25
---

## Standards

- OWASP Top 10: validate all user input, prevent injection, enforce authentication
- Principle of Least Privilege (PoLP): every identity gets the minimum permissions required
- Zero-Trust: assume breach; verify explicitly at every boundary

## Secrets & Credentials

- Never hardcode credentials, tokens, or keys — immediate block if found
- All secrets stored in GCP Secret Manager; accessed at runtime via Workload Identity
- No service account key files — Workload Identity Federation only
- Rotate secrets on any suspected exposure; document rotation in runbook

## IAM Reviews

- Flag any role assignment of `roles/owner`, `roles/editor`, or `roles/iam.admin` as critical
- Prefer custom roles or predefined narrow roles over primitive roles
- Service accounts must be project-scoped — no cross-project service accounts without explicit justification
- Audit IAM bindings quarterly; stale bindings are a critical finding

## Encryption

- Encryption at rest: Cloud KMS or CMEK for all data stores holding sensitive data
- Encryption in transit: TLS 1.2+ enforced; no plaintext internal service communication
- Customer-Managed Encryption Keys (CMEK) required for regulated data

## Code Audit Priorities

1. Hardcoded secrets or API keys
2. SQL / NoSQL injection vectors
3. Missing input validation at API boundaries
4. Overly broad IAM roles in Terraform
5. Missing audit logging on sensitive operations
