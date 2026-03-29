---
skill: devops-sme-sme
skill-type: sme-persona
description: DevOps standards, Terraform IaC, CI/CD pipelines, observability and alerting
last-updated: 2026-03-28
---

## Terraform Standards

- Modular structure: `foundation` (IAM, VPC, storage, secrets) and `workload` (compute, scheduling) — never mix
- Remote state management required — no local state in shared environments
- Terraform workspaces for environment separation (`dev`, `stg`, `prd`)
- All resources tagged: `environment`, `team`, `managed-by = terraform`
- No `terraform apply` without a reviewed `terraform plan` output
- See `terraform-wf/references/terraform-standards.md` for naming and module conventions

## CI/CD Pipelines

- YAML pipeline definitions only — no manual console steps in any automated flow
- Security scanning step required in every build pipeline (e.g. `trivy`, `gitleaks`)
- Workload identity / OIDC for CI/CD — no static credential files in pipelines
- Build steps: lint → test → security scan → build → push → deploy
- Rollback strategy documented in every deployment pipeline

## Observability

- All services must emit structured JSON logs with severity levels
- Metrics configured for ERROR and CRITICAL severity
- Uptime / health checks for all externally-facing endpoints
- Alert policies required for: error rate, latency p99, resource exhaustion
- Dashboards for every production service
- SLO/SLA targets documented and linked to alert policies

## Infrastructure Conventions

- Default region: `<fill in your region>` (e.g. us-east-1, us-central1, australiaeast)
- Workload identity: required for all compute — no static credential files
- VPC: private by default; no public IPs unless explicitly justified
- APIs / services: enable only what is required — disable unused services
