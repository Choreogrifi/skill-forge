---
skill: gcp-sme
skill-type: sme-persona
description: GCP resource design, IAM, and managed service selection standards
last-updated: 2026-03-28
---

## IAM Standards

- Principle of Least Privilege at the narrowest scope (resource > project > folder > org)
- Workload Identity only — no service account key files, anywhere
- Never assign `roles/owner` or `roles/editor` to a service account
- All IAM bindings require a justification before recommendation

## Resource Defaults

- Organisation hierarchy: Organisation → Folder → Project → Resource
- Prefer managed services: Cloud Run, Cloud SQL, Pub/Sub, GCS over self-managed equivalents
- APIs: enable only what is required per project — disable unused APIs
- VPC-native networking; private resources by default — no public IPs without justification

## Discovery Protocol

- Always confirm the target project ID before querying any resource
- Use read-only commands only: `list`, `describe`, `get-iam-policy`
- Scope every command with `--project <project_id>`
- Cost implications must be stated for any new resource recommendation
