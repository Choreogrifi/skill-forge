# PWD Terraform Standards

Derived from `/Users/leond/development/in-store-stock/in-store-stock-worker/terraform`.

---

## Directory Layout

```
terraform/
├── main.tf               # Root orchestration — module declarations only
├── provider.tf           # Provider block (project + region from vars)
├── variables.tf          # All root input variables
├── outputs.tf            # Root outputs (repo URL, job name, SA identity)
├── common.tfvars         # Shared values across all environments
├── dev.tfvars            # Environment-specific overrides
├── prd.tfvars
├── tst.tfvars
└── modules/
    ├── foundation/       # Infrastructure layer: APIs, IAM, VPC, storage, secrets
    │   ├── variables.tf
    │   ├── outputs.tf
    │   ├── apis.tf
    │   ├── iam.tf
    │   ├── vpc.tf
    │   ├── storage.tf
    │   └── secrets.tf
    └── workload/         # Application layer: compute, scheduling
        ├── variables.tf
        ├── outputs.tf
        ├── cloudrun.tf
        └── scheduler.tf
```

---

## Module Separation (SoC + SRP)

| Module | Responsibility | Must NOT contain |
|---|---|---|
| `foundation` | APIs, IAM SAs, VPC, Artifact Registry, Secret Manager | Any compute resources |
| `workload` | Cloud Run Jobs, Cloud Scheduler | Any IAM or networking resources |

- `workload` always declares `depends_on = [module.foundation]`.
- Foundation outputs identities and resource IDs; workload consumes them as string vars — never uses data sources to look up what foundation already created.

---

## Module Wiring Pattern

Root `main.tf` calls both modules; workload receives foundation outputs as explicit variable inputs:

```hcl
module "foundation" {
  source       = "./modules/foundation"
  project_id   = var.project_id
  region       = var.region
  product_name = var.product_name
  module_name  = var.module_name
  # ...domain-specific vars
}

module "workload" {
  source                = "./modules/workload"
  project_id            = var.project_id
  region                = var.region
  product_name          = var.product_name
  module_name           = var.module_name
  worker_sa_identity    = module.foundation.worker_sa_identity
  scheduler_sa_identity = module.foundation.scheduler_sa_identity
  vpc_connector_id      = module.foundation.vpc_connector_id
  repo_id               = module.foundation.repo_id
  depends_on            = [module.foundation]
}
```

---

## Variable & Tfvars Pattern

- `common.tfvars` holds values that are environment-invariant: `region`, `product_name`, `module_name`, dataset/table IDs.
- Environment tfvars (`dev.tfvars`, `prd.tfvars`, `tst.tfvars`) override only what differs: `project_id`, `sync_schedule`.
- Apply with: `terraform plan -var-file=common.tfvars -var-file=dev.tfvars`
- All variables must have a `description` field. Defaults are allowed for non-sensitive values.

---

## Naming Convention

Pattern: `${var.product_name}-${var.module_name}-${resource_suffix}`

| Resource type | Suffix | Example |
|---|---|---|
| Worker service account | `sa` | `in-store-stock-worker-sa` |
| Scheduler service account | `sched-sa` | `in-store-stock-worker-sched-sa` |
| Cloud Run Job | `job` | `in-store-stock-worker-job` |
| Cloud Scheduler | `schedule` | `in-store-stock-worker-schedule` |
| Subnet | `sn` | `in-store-stock-worker-sn` |
| VPC Connector | `vpc-conn` | `in-store-stock-vpc-conn` |
| Artifact Registry | `repo` | `in-store-stock-repo` |
| Redis instance | `cache` | `in-store-stock-cache` |
| VPC network | `${project_id}-vpc` | `grp-dev-vpc` (project-scoped) |

---

## Workspace-Aware Configuration

Use `terraform.workspace` for environment-differentiated values — never use tfvars for these:

```hcl
tier       = terraform.workspace == "prod" ? "STANDARD_HA" : "BASIC"
cidr_range = terraform.workspace == "prod" ? "10.8.1.0/28" : "10.8.0.0/28"
log_level  = terraform.workspace == "prod" ? "info" : "debug"
```

Workspace names: `dev`, `tst`, `prod`.

---

## IAM Least-Privilege Pattern

- Every workload gets its own dedicated service account — never reuse SAs across workloads.
- Scheduler SA gets only `run.invoker` on the specific job.
- Worker SA gets only the roles its code needs (e.g. `bigquery.dataViewer`, `secretmanager.secretAccessor`).
- Cloud Build SA gets `run.admin` + `iam.serviceAccountUser` for CI/CD deployments.
- Use `data.google_project.project` to fetch project number for Cloud Build identity.

---

## API Enablement Pattern

Declare all required APIs in one resource using `for_each`:

```hcl
resource "google_project_service" "apis" {
  for_each           = toset(local.required_apis)
  project            = var.project_id
  service            = each.key
  disable_on_destroy = false
}
```

All other resources that require an API must declare `depends_on = [google_project_service.apis]`.

---

## Secrets Pattern

Use `locals` + `for_each` for declarative secret management. Never inline secret values:

```hcl
locals {
  shared_secrets = { "DATASET_ID" = var.bigquery_dataset_id, ... }
  unique_secrets = { "STK_TABLE_ID" = var.bigquery_table_id, ... }
}

resource "google_secret_manager_secret" "shared" {
  for_each  = local.shared_secrets
  secret_id = each.key
  ...
}
```

Cache URLs and other derived secrets are built from resource outputs, not hardcoded.

---

## Provider Configuration

```hcl
provider "google" {
  project = var.project_id
  region  = var.region
}
```

Provider version pinned in `.terraform.lock.hcl`. Current: `google ~= 7.17.0`.

---

## Lifecycle Rules

For resources whose attributes are managed externally (e.g. container image tags managed by CI/CD):

```hcl
lifecycle {
  ignore_changes = [template[0].template[0].containers[0].image]
}
```

---

## Root Outputs

Always expose at minimum:
- `repository_url` — Docker registry URL for CI/CD
- `job_name` — workload job name for CI/CD triggers
- `service_account_identity` — worker SA email for downstream IAM grants
