# Terraform Standards

> **This file is a template.** Replace the placeholder examples with your project's actual conventions.
> The `terraform-wf` skill reads this file to generate HCL that matches your project's patterns.

---

## Directory Layout

```
terraform/
├── main.tf               # Root orchestration — module declarations only
├── provider.tf           # Provider block (project + region from vars)
├── variables.tf          # All root input variables
├── outputs.tf            # Root outputs
├── common.tfvars         # Shared values across all environments
├── dev.tfvars            # Environment-specific overrides
├── prd.tfvars
└── modules/
    ├── foundation/       # Infrastructure layer: APIs, IAM, VPC, storage, secrets
    │   ├── variables.tf
    │   ├── outputs.tf
    │   ├── iam.tf
    │   └── ...
    └── workload/         # Application layer: compute, scheduling
        ├── variables.tf
        ├── outputs.tf
        └── ...
```

---

## Module Separation (SoC + SRP)

| Module | Responsibility | Must NOT contain |
|---|---|---|
| `foundation` | APIs, IAM, VPC, storage, secrets | Any compute resources |
| `workload` | Compute, scheduling | Any IAM or networking resources |

- `workload` always declares `depends_on = [module.foundation]`.
- Foundation outputs identities and resource IDs; workload consumes them as string vars.

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
}

module "workload" {
  source       = "./modules/workload"
  project_id   = var.project_id
  region       = var.region
  product_name = var.product_name
  module_name  = var.module_name
  # Pass foundation outputs as explicit inputs
  worker_sa_identity = module.foundation.worker_sa_identity
  depends_on         = [module.foundation]
}
```

---

## Variable & Tfvars Pattern

- `common.tfvars` holds environment-invariant values: `region`, `product_name`, `module_name`.
- Environment tfvars (`dev.tfvars`, `prd.tfvars`) override only what differs: `project_id`, schedules.
- Apply with: `terraform plan -var-file=common.tfvars -var-file=dev.tfvars`
- All variables must have a `description` field.

---

## Naming Convention

Pattern: `${var.product_name}-${var.module_name}-${resource_suffix}`

| Resource type | Suffix | Example |
|---|---|---|
| Worker service account | `sa` | `<product>-<module>-sa` |
| Compute job | `job` | `<product>-<module>-job` |
| Scheduler | `schedule` | `<product>-<module>-schedule` |
| Subnet | `sn` | `<product>-<module>-sn` |
| Container registry | `repo` | `<product>-repo` |

---

## Workspace-Aware Configuration

Use `terraform.workspace` for environment-differentiated values:

```hcl
tier      = terraform.workspace == "prd" ? "STANDARD" : "BASIC"
log_level = terraform.workspace == "prd" ? "info" : "debug"
```

Workspace names: `dev`, `prd` (adjust to your project's naming).

---

## IAM Least-Privilege Pattern

- Every workload gets its own dedicated service account — never reuse accounts across workloads.
- Grants are scoped to the narrowest applicable role and resource.
- CI/CD service accounts get only what is needed for deployment operations.

---

## Secrets Pattern

Use `locals` + `for_each` for declarative secret management. Never inline secret values:

```hcl
locals {
  secrets = { "DB_PASSWORD" = var.db_password_ref }
}

resource "<provider>_secret" "app" {
  for_each  = local.secrets
  secret_id = each.key
}
```

---

## Provider Configuration

```hcl
provider "<cloud>" {
  project = var.project_id
  region  = var.region
}
```

Pin provider versions in `.terraform.lock.hcl`.

---

## Lifecycle Rules

For resources whose attributes are managed externally (e.g. image tags managed by CI/CD):

```hcl
lifecycle {
  ignore_changes = [image]
}
```

---

## Root Outputs

Always expose at minimum:
- `registry_url` — container registry URL for CI/CD
- `job_name` — compute job name for CI/CD triggers
- `service_account_email` — worker identity for downstream IAM grants
