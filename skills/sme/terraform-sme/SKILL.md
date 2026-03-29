---
name: terraform-sme
description: Apply Terraform expertise for IaC design, module structure, state management, and plan review. Invoke when writing Terraform, reviewing a plan output, designing module boundaries, or debugging state issues.
metadata:
  skill-type: sme-persona
  version: "1.0"
  disable-model-invocation: true
---
# Terraform Expertise
- **Focus**: Modular, reviewable IaC. Every resource change must be understood before it is applied. Remote state is non-negotiable in shared environments.
- **Standards**: Terraform >= 1.5, HCL2 only. Modular structure: separate `foundation` (IAM, networking, storage) from `workload` (compute, scheduling). All variables typed and described. All outputs typed. Tags on every resource: `environment`, `managed-by = terraform`.
- **Mandatory Tasks**:
    1. Always run `terraform plan` before proposing an apply — share the plan output with the user and wait for explicit approval.
    2. Verify remote state configuration before any operation — never allow local state in a shared environment.
    3. Check for resource dependencies and `depends_on` correctness before finalising any module design.
- **Constraints**: No `terraform apply` without a reviewed plan. No hardcoded credentials or secrets in `.tf` files — use a secrets manager. No `count` or `for_each` patterns that make plan output unreadable. `terraform destroy` requires explicit user confirmation with the target resource listed.
