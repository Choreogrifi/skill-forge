# Terraform Scan Subflow

Reads the application codebase and infers what cloud infrastructure it requires. Produces a structured resource proposal that `terraform-wf` consumes to pre-populate its HCL generation step. Does not write any files — output only.

## Focus

Derive infrastructure intent from code signals: runtime, dependencies, environment variable names, config files, Dockerfiles, CI/CD pipelines, and service clients. Map every signal to a resource category following the module separation used in the project's Terraform standards.

## Standards

- Scan broadly before concluding — check all of: `Dockerfile`, `package.json` / `requirements.txt` / `go.mod`, `.env.example`, `docker-compose.yml`, CI pipeline files, source imports, and any existing config files.
- Map application signals to resource categories using `references/signal-to-resource-map.md`.
- Group every proposed resource into either `foundation` (APIs, IAM, VPC, storage, secrets) or `workload` (compute, scheduling) — never mix.
- Flag ambiguous signals with a confidence level: `high`, `medium`, or `low`.
- Never invent resources that have no signal in the code.

## Mandatory Tasks

1. **Scan** the codebase for infrastructure signals. Read `references/signal-to-resource-map.md` during this step.
2. **Map** each signal to a resource category and module layer (foundation or workload).
3. **Propose** a structured resource plan in the standard output format below and present it to the caller.

## Output Format

Return a structured proposal — this is consumed directly by `terraform-wf`:

```
Terraform Discovery Report
──────────────────────────
Runtime:       <detected runtime, e.g. Node.js 20, Python 3.11, Go 1.22>
Trigger:       <how the workload is invoked, e.g. HTTP, message queue, cron>

Foundation resources:
  [high]   <provider>_project_service / api_enablement  — services: <list>
  [high]   <provider>_service_account / iam_role        — worker identity (least-privilege)
  [medium] <provider>_vpc_network                       — private networking (cache/private service detected)
  [medium] <provider>_cache_instance                    — cache client detected
  [high]   <provider>_secret                            — env vars: <list of detected secret names>
  [low]    <provider>_container_registry                — Dockerfile present

Workload resources:
  [high]   <provider>_job / container_job               — batch/job pattern detected
  [medium] <provider>_scheduler / cron_job              — cron config detected

Suggested variables:
  product_name  = "<inferred from repo/package name>"
  module_name   = "<inferred from entry point or service name>"

Ambiguous signals:
  <signal> → could be <resource A> or <resource B> — needs clarification
```

> Replace `<provider>_*` placeholders with your cloud provider's actual Terraform resource names
> (e.g. `google_`, `aws_`, `azurerm_`). See `references/signal-to-resource-map.md` for a mapping.

## Constraints

- **Read only** — never create, modify, or delete files.
- **No invention** — every proposed resource must trace back to at least one code signal.
- **No credentials** — if secret values are visible in code, flag them as a security issue; do not include them in the proposal.

## References

- `references/signal-to-resource-map.md` — mapping of code signals (imports, env vars, config patterns) to resource categories; read during the Scan step
