# GCP Scan Subflow

Queries a GCP project for resources of a specific type. Designed for programmatic
callers (e.g. `terraform-wf`) that need a targeted list rather than a full inventory.

## When to Use

Invoke when a caller needs resources of one service area to cross-reference against
existing Terraform state or application configuration.

## Workflow

### 1. Collect Inputs

Accept from caller or ask:
```
GCP project ID:
Resource types to scan (e.g. cloud-run, gcs, iam, secrets, all):
```

If called by `terraform-wf`, these values are passed automatically.

### 2. Run Targeted Commands

Read `references/gcloud-discovery-commands.md` and execute only the commands matching
the requested resource types. Scope every command with `--project <project_id>`.

If a command fails: log the skip reason and continue.

### 3. Return Structured Output

Output is concise and machine-readable for the caller:

```
GCP Scan: <project_id>  |  Types: <requested_types>
───────────────────────────────────────────────────
Cloud Run Services:    <name> (<region>)
Cloud Run Jobs:        <name> (<region>)
GCS Buckets:           <name>
IAM Service Accounts:  <email> — roles: <role>
Secret Manager:        <secret_id>
Errors:                <service>: <reason>
```

Each existing resource is tagged `[existing]` when the output is consumed by `terraform-wf`.

### 4. Return to Caller

Hand the structured output back to the calling workflow. Do not ask for next steps —
the caller controls the flow.

## Guidelines

- Read-only — no mutating commands.
- Always pass `--project` to every command.
- When called by `terraform-wf`, mark every discovered resource as `[existing]` to
  distinguish from `[new]` resources in the Terraform proposal.
