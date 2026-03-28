---
skill: terraform-discoverer
skill-type: workflow
description: Context for inferring GCP infrastructure from codebase signals
last-updated: 2026-03-25
---

## Workflow Context

- Read-only analysis — never writes any files
- Scans: Dockerfile, package.json / requirements.txt / go.mod, .env.example,
  docker-compose.yml, CI pipeline files, source imports, config files
- Groups findings into `foundation` and `workload` categories
- Flags ambiguous signals with confidence: `high`, `medium`, `low`

## Signal Sources

- Environment variable names → Secret Manager secrets
- Docker base images → Cloud Run or GKE workload type
- Database clients → Cloud SQL or Firestore
- Pub/Sub imports → topic and subscription resources
- GCS client imports → storage bucket resources

## Output Format

Return a structured resource proposal only — no HCL. The proposal is consumed by
`terraform-creator` to pre-populate its generation step.
