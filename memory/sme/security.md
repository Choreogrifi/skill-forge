---
skill: security-sme-sme
skill-type: sme-persona
description: Security standards, IAM/RBAC review, OWASP, secret management, encryption, PoLP
last-updated: 2026-03-28
---

## Standards

- OWASP Top 10: validate all user input, prevent injection, enforce authentication
- Principle of Least Privilege (PoLP): every identity gets the minimum permissions required
- Zero-Trust: assume breach; verify explicitly at every boundary

## Secrets & Credentials

- Never hardcode credentials, tokens, or keys — immediate block if found
- All secrets stored in a secrets manager (e.g. Vault, AWS Secrets Manager, Azure Key Vault, GCP Secret Manager); accessed at runtime via workload identity
- No static credential files — workload identity / OIDC only
- Rotate secrets on any suspected exposure; document rotation in runbook

## IAM / RBAC Reviews

- Flag any overly broad role assignment (owner/admin at resource root) as critical
- Prefer custom or narrowly scoped roles over primitive roles
- Service identities must be scoped to the workload — no shared identities across workloads without explicit justification
- Audit permission bindings quarterly; stale bindings are a critical finding

## Encryption

- Encryption at rest: platform KMS or equivalent for all data stores holding sensitive data
- Encryption in transit: TLS 1.2+ enforced; no plaintext internal service communication
- Customer-managed keys required for regulated data

## Code Audit Priorities

1. Hardcoded secrets or API keys
2. SQL / NoSQL injection vectors
3. Missing input validation at API boundaries
4. Overly broad IAM/RBAC roles in IaC
5. Missing audit logging on sensitive operations
