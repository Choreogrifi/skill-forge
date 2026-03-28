---
skill: terraform-creator
skill-type: workflow
description: Context for scaffolding new Terraform HCL — conventions, state, module structure
last-updated: 2026-03-25
---

## Workflow Context

- Reads existing `./terraform` folder before generating anything — never create HCL blind
- Invokes `terraform-discoverer` if no `./terraform` folder exists (codebase inference)
- Optionally invokes `gcp-project-discoverer` to cross-reference live GCP state
- All proposed resources must be shown to the user before writing

## Module Structure

- Separate modules: `foundation` (IAM, APIs, VPC, secrets, storage) and `workload` (compute, scheduling)
- Never mix foundation and workload resources in the same module
- Remote GCS state required — no local state files in any environment

## Key Conventions

- Provider block: `google` and `google-beta`, pinned version
- Backend block: GCS with prefix per environment
- Variable files: `variables.tf`, `outputs.tf`, `main.tf`, `versions.tf` — no monolithic files
- Naming: all resources follow `<team>-<env>-<resource-type>` pattern

## Design Decision Trigger

If a resource requires an architectural choice (e.g., Cloud Run vs GKE, Pub/Sub vs Cloud Tasks),
pause and invoke the `architect` SME before proceeding.
