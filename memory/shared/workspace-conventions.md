<!-- EDIT THIS FILE — replace all {{PLACEHOLDER}} values with your own details -->
---
type: shared
description: Cross-cutting workspace conventions — cloud registry, naming patterns, tool standards
last-updated: {{YYYY-MM-DD}}
---

## Cloud Project Registry

<!-- Populate with actual project IDs as they are confirmed -->
- Default region: `{{YOUR_CLOUD_REGION}}` (e.g. us-central1, us-east-1, australiaeast)
- Project naming pattern: `{{YOUR_PROJECT_PATTERN}}` (e.g. `<team>-<env>-<service>`)
- State/storage bucket pattern: `{{YOUR_BUCKET_PATTERN}}` (e.g. `gs://<team>-terraform-state`)
- Container registry pattern: `{{YOUR_REGISTRY_PATTERN}}` (e.g. `<region>-docker.pkg.dev/<project>/images`)

## Naming Conventions

- Resources: {{YOUR_RESOURCE_NAMING}} (e.g. lowercase, hyphen-separated)
- IaC modules: {{YOUR_IaC_NAMING}} (e.g. noun-first: `service-account`, `cloud-run`)
- Python packages: {{YOUR_PYTHON_NAMING}} (e.g. snake_case)
- TypeScript packages: {{YOUR_TS_NAMING}} (e.g. kebab-case)
- Environment suffixes: {{YOUR_ENV_SUFFIXES}} (e.g. `-dev`, `-stg`, `-prd`)

## Tool Versions & Standards

- IaC tool: {{YOUR_IAC_VERSION}} (e.g. Terraform >= 1.5)
- Python: {{YOUR_PYTHON_VERSION}} (e.g. >= 3.11, type hints required)
- TypeScript: {{YOUR_TS_CONFIG}} (e.g. strict mode, no `any`)
- Node: {{YOUR_NODE_VERSION}} (e.g. LTS)
- Docker: {{YOUR_DOCKER_STANDARD}} (e.g. multi-stage builds, non-root user)

## Repository Conventions

- Branch naming: `{{YOUR_BRANCH_PATTERN}}` (e.g. `feat/<ticket>-<description>`)
- Commit style: `{{YOUR_COMMIT_STYLE}}` (e.g. conventional commits: `feat:`, `fix:`, `chore:`)
- PR size: `{{YOUR_PR_SIZE_LIMIT}}` (e.g. < 400 lines changed preferred)

## Example (delete this section after filling in your details above)

```
## Cloud Project Registry
- Default region: us-east-1
- Project naming pattern: <team>-<env>-<service>
```
