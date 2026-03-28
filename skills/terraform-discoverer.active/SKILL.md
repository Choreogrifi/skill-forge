---
name: terraform-discoverer
skill-type: workflow
memory-file: workflow/terraform-discoverer.md
description: Analyses a codebase to infer the GCP infrastructure it requires and proposes a structured Terraform resource plan. Invoked by terraform-creator when no ./terraform folder exists. Also invoke directly when you want a Terraform proposal derived from application code alone.
disable-model-invocation: true
---

# Terraform Discoverer

Reads the application codebase in the current working directory and infers what GCP infrastructure the application requires. Produces a structured resource proposal that `terraform-creator` consumes to pre-populate its HCL generation step. Does not write any files — output only.

## Focus

Derive infrastructure intent from code signals: runtime, dependencies, environment variable names, config files, Dockerfiles, CI/CD pipelines, and service clients. Map every signal to a specific GCP resource type following the same module separation used in the project's Terraform standards.

## Standards

- Scan broadly before concluding — check all of: `Dockerfile`, `package.json` / `requirements.txt` / `go.mod`, `.env.example`, `docker-compose.yml`, CI pipeline files, source imports, and any existing config files.
- Map application signals to GCP resource types using `references/signal-to-resource-map.md`.
- Group every proposed resource into either `foundation` (APIs, IAM, VPC, storage, secrets) or `workload` (compute, scheduling) — never mix.
- Flag ambiguous signals with a confidence level: `high`, `medium`, or `low`.
- Never invent resources that have no signal in the code.

## Mandatory Tasks

1. **Scan** the codebase for infrastructure signals. Read `references/signal-to-resource-map.md` during this step.
2. **Map** each signal to a GCP resource type and module layer (foundation or workload).
3. **Propose** a structured resource plan in the standard output format below and present it to the caller.

## Output Format

Return a structured proposal — this is consumed directly by `terraform-creator`:

```
Terraform Discovery Report
──────────────────────────
Runtime:       <detected runtime, e.g. Node.js 20, Python 3.11>
Trigger:       <how the workload is invoked, e.g. HTTP, Pub/Sub, Cloud Scheduler>

Foundation resources:
  [high]   google_project_service         — APIs: run, secretmanager, bigquery, ...
  [high]   google_service_account         — worker SA (least-privilege)
  [medium] google_vpc_network             — custom VPC (Redis/private service detected)
  [medium] google_vpc_access_connector    — serverless VPC access
  [medium] google_redis_instance          — cache client detected
  [high]   google_secret_manager_secret   — env vars: <list of detected secret names>
  [low]    google_artifact_registry_repository — Dockerfile present

Workload resources:
  [high]   google_cloud_run_v2_job        — batch/job pattern detected
  [medium] google_cloud_scheduler_job     — cron config detected

Suggested variables:
  product_name  = "<inferred from repo/package name>"
  module_name   = "<inferred from entry point or service name>"

Ambiguous signals:
  <signal> → could be <resource A> or <resource B> — needs clarification
```

## Constraints

- **Read only** — never create, modify, or delete files.
- **No invention** — every proposed resource must trace back to at least one code signal.
- **No credentials** — if secret values are visible in code, flag them as a security issue; do not include them in the proposal.

## References

- `references/signal-to-resource-map.md` — mapping of code signals (imports, env vars, config patterns) to GCP resource types; read during the Scan step
