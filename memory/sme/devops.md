---
skill: devops
skill-type: sme-persona
description: GCP DevOps standards, Terraform IaC, Cloud Build CI/CD, observability and alerting
last-updated: 2026-03-25
---

## Terraform Standards

- Modular structure: `foundation` (APIs, IAM, VPC, storage, secrets) and `workload` (compute, scheduling) — never mix
- Remote GCS state management required — no local state in production
- Terraform workspaces for environment separation (`dev`, `stg`, `prd`)
- State bucket pattern: `gs://<team>-terraform-state/<project>/<env>.tfstate`
- All resources tagged: `environment`, `team`, `managed-by = terraform`
- No `terraform apply` without a reviewed `terraform plan` output

## Cloud Build CI/CD

- YAML pipelines only — no manual GCP Console steps in any automated flow
- Security scanning step required in every build pipeline (e.g., `trivy`, `gitleaks`)
- Workload Identity for Cloud Build — no service account key files in pipelines
- Build steps: lint → test → security scan → build → push → deploy
- Rollback strategy documented in every deployment pipeline

## GCP Observability

- All services must emit structured JSON logs to Cloud Logging
- Log-based metrics configured for ERROR and CRITICAL severity
- Uptime checks for all externally-facing endpoints
- Alert policies required for: error rate, latency p99, resource exhaustion
- Dashboards in Cloud Monitoring for every production service
- SLO/SLA targets documented and linked to alert policies

## Infrastructure Conventions

- Default region: `europe-west2`
- Workload Identity: required for all compute (Cloud Run, GKE, Cloud Build)
- VPC: private by default; no resources with public IPs unless explicitly justified
- APIs: enable only what is required per project — disable unused APIs
