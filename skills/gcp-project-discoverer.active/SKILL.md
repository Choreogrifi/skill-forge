---
name: gcp-project-discoverer
skill-type: workflow
memory-file: workflow/gcp-project-discoverer.md
description: Discovers existing GCP resources in a given project using gcloud CLI and returns a structured as-is inventory. Invoked by terraform-creator when bootstrapping a new terraform folder to cross-reference live infrastructure. Also invoke directly when you need an inventory of a GCP project.
disable-model-invocation: true
---

# GCP Project Discoverer

Queries a live GCP project via `gcloud` CLI to produce a structured inventory of existing resources. The inventory is consumed by `terraform-creator` to inform HCL generation — ensuring proposed code reflects what is already deployed and avoids duplicating resources.

## Focus

Use `gcloud` read-only commands to enumerate resources across the most common GCP service areas. Group findings by service. Present a clean, structured inventory that a Terraform author can use as an as-is baseline.

## Standards

- Always ask for the GCP project ID before running any command.
- Use only read-only `gcloud` commands (`list`, `describe`, `get-iam-policy`). Never run mutating commands.
- Scope every command to the specified project using `--project <project_id>`.
- If a `gcloud` command fails (permission denied, API not enabled), note the failure and continue — do not abort.
- Group output by GCP service area, not by resource type.

## Mandatory Tasks

1. **Collect** the GCP project ID from the caller or prompt: `"GCP project ID to inspect:"`.
2. **Query** each service area using the commands in `references/gcloud-discovery-commands.md`. Read that file during this step.
3. **Present** the structured inventory in the standard output format below.

## Output Format

```
GCP Project Inventory: <project_id>
─────────────────────────────────────
Compute / Cloud Run
  Jobs:        <name>, <name>
  Services:    <name>, <name>

IAM / Service Accounts
  <email>  — roles: <role1>, <role2>

Networking
  VPC Networks:      <name>
  Subnets:           <name> (<region>, <cidr>)
  VPC Connectors:    <name>

Storage / Registries
  Artifact Registry: <repo_name> (<format>, <region>)
  GCS Buckets:       <name>

Data
  BigQuery Datasets: <dataset_id>
  Memorystore:       <name> (<tier>, <size>GB)

Secrets
  Secret Manager:    <secret_id>, <secret_id>, ...

Scheduler
  Cloud Scheduler:   <job_name> (<schedule>)

APIs Enabled
  <api>, <api>, ...

Errors / Skipped
  <service>: <reason>
```

## Constraints

- **Read only** — never run any command that creates, updates, or deletes resources.
- **No secret values** — list secret names only; never retrieve or display secret data.
- **Project-scoped** — always pass `--project` to every command; never operate on the default project.
- **Graceful degradation** — a missing permission or disabled API is a logged skip, not a failure.

## References

- `references/gcloud-discovery-commands.md` — full list of read-only gcloud commands per service area; read during the Query step
