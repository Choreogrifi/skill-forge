---
skill: gcp-project-discoverer
skill-type: workflow
description: Context for live GCP resource inventory via gcloud CLI
last-updated: 2026-03-25
---

## Workflow Context

- Always ask for GCP project ID before running any command
- Read-only gcloud commands only: `list`, `describe`, `get-iam-policy`
- Scope every command with `--project <project_id>`
- If a command fails (permission denied, API not enabled): note and continue — do not abort
- Output: structured inventory grouped by GCP service area

## Key Service Areas to Scan

- Cloud Run services
- Cloud Functions
- Cloud SQL instances
- GCS buckets
- Pub/Sub topics and subscriptions
- Secret Manager secrets
- IAM service accounts and bindings
- VPC networks and subnets
- Artifact Registry repositories
