---
type: shared
description: Cross-cutting workspace conventions — GCP registry, naming patterns, tool standards
last-updated: 2026-03-25
---

## GCP Project Registry

<!-- Populate with actual project IDs as they are confirmed -->
- Default region: `europe-west2`
- Project naming pattern: `<team>-<env>-<service>` (e.g., `ea-dev-agent`, `ea-prd-api`)
- Terraform state bucket pattern: `gs://<team>-terraform-state`
- Artifact Registry pattern: `europe-west2-docker.pkg.dev/<project-id>/images`

## Naming Conventions

- Resources: lowercase, hyphen-separated (`cloud-run-service`, not `cloudRunService`)
- Terraform modules: noun-first (`service-account`, `cloud-run`, `pubsub-topic`)
- Python packages: snake_case; TypeScript packages: kebab-case
- Environment suffixes: `-dev`, `-stg`, `-prd`

## Tool Versions & Standards

- Terraform: >= 1.5, HCL2 only
- Python: >= 3.11, type hints required everywhere
- TypeScript: strict mode, no `any`
- Node: LTS version
- Docker: multi-stage builds, non-root user enforced

## Repository Conventions

- Branch naming: `feat/<ticket>-<short-description>`, `fix/<ticket>-<description>`
- Commit style: conventional commits (`feat:`, `fix:`, `chore:`, `docs:`)
- PR size: < 400 lines changed preferred; larger changes require explicit justification
