# GCP Discover Subflow

Performs a full inventory of all resources in a GCP project. Used for as-is baseline
documentation and infrastructure auditing.

## Workflow

### 1. Collect Project ID

Ask:
```
GCP project ID to inspect:
```

Confirm before running any commands.

### 2. Query All Service Areas

Read `references/gcloud-discovery-commands.md` to load the command list. Execute each
read-only command scoped to the project. Group results by GCP service area.

If a command fails (permission denied, API not enabled): log the failure with the reason
and continue — do not abort the discovery.

### 3. Present Inventory

Output the structured inventory in the standard format:

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

Storage / Registries
  Artifact Registry: <repo_name> (<format>, <region>)
  GCS Buckets:       <name>

Data
  BigQuery Datasets: <dataset_id>
  Memorystore:       <name> (<tier>, <size>GB)

Secrets
  Secret Manager:    <secret_id>, ...

Scheduler
  Cloud Scheduler:   <job_name> (<schedule>)

APIs Enabled
  <api>, <api>, ...

Errors / Skipped
  <service>: <reason>
```

### 4. Offer Next Steps

```
What would you like to do with this inventory?
  1. Use as input for Terraform scaffolding (hand off to terraform-wf)
  2. Save to a file
  3. Done

Enter 1–3:
```

## Guidelines

- Read-only — never run commands that create, update, or delete resources.
- List secret names only — never retrieve or display secret values.
- Always pass `--project` to every command.
