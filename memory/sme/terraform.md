---
skill: terraform-sme
skill-type: sme-persona
description: Terraform IaC standards — module structure, state management, plan review conventions
last-updated: 2026-03-28
---

## Module Structure

- Separate modules: `foundation` (IAM, APIs, VPC, secrets, storage) and `workload` (compute, scheduling)
- Never mix foundation and workload concerns in a single module
- Every module must have `variables.tf`, `outputs.tf`, `main.tf` — no monolithic files

## State Management

- Remote state (S3, GCS, Azure Blob, Terraform Cloud, etc.) required in shared or production environments
- State backend pattern: `<backend>/<team>/<project>/<env>.tfstate`
- Never allow local state files in shared environments

## Plan Discipline

- Always run `terraform plan` before proposing `apply` — share the plan output with the user
- Never run `terraform apply` without explicit user approval of the reviewed plan
- `terraform destroy` requires explicit user confirmation with the target resource listed

## Conventions

- Terraform >= 1.5, HCL2 only
- All variables must be typed and described; all outputs typed
- Tags on every resource: `environment`, `managed-by = terraform`
