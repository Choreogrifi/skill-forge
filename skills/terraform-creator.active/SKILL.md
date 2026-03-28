---
name: terraform-creator
skill-type: workflow
memory-file: workflow/terraform-creator.md
description: Guided workflow to scaffold Terraform HCL in the current project. Detects an existing ./terraform folder and reads environment state to understand as-is; if absent, bootstraps the folder and invokes terraform-discoverer (codebase analysis) and optionally gcp-project-discoverer (live GCP inventory). Invoke when adding a new module, resource, or workload to a GCP project.
disable-model-invocation: true
---

# Terraform Creator

Scaffolds new Terraform HCL that conforms to the project's established conventions. Reads existing state to understand what is already deployed before generating anything new. If no Terraform folder exists, bootstraps one using `terraform-discoverer` to analyse the codebase and optionally `gcp-project-discoverer` to cross-reference live GCP infrastructure.

## Workflow

### 1. Detect Terraform Folder

Check if a `./terraform` directory exists in the current working directory.

**If `./terraform` exists:**
- Run `terraform workspace show` from within `./terraform` to identify the active environment.
- Look for a state file at `./terraform/terraform.tfstate.d/<env>/terraform.tfstate` where `<env>` is the value returned by the command.
- If found, read it and extract the list of managed resource types and names.
- Present a brief as-is summary:
  ```
  As-is (env: <env>)
  ──────────────────
  <resource_type>: <resource_name>
  ...
  ```
- Read `references/pwd-terraform-standards.md` to load the project conventions.
- Proceed to Step 2.

**If `./terraform` does not exist:**
- Inform the user: "No terraform folder found. I'll bootstrap one."
- Create the `./terraform` directory.
- Invoke `terraform-discoverer` to analyse the codebase and produce a proposed resource plan. Hold this output as the **discovery baseline**.
- Ask the user: "Would you like me to cross-reference a live GCP project to refine the proposal? (yes / no)"
  - If yes: invoke `gcp-project-discoverer`, which will prompt for the GCP project ID. Merge its inventory with the discovery baseline — resources already present in GCP are marked `[existing]`; new resources are marked `[new]`.
  - If no: continue with the discovery baseline alone; all proposed resources are marked `[new]`.
- Read `references/pwd-terraform-standards.md` to load the project conventions.
- Proceed to Step 2 with the discovery baseline pre-populating resource selections and variable suggestions.

### 2. Gather Requirements

Ask the user what they want to create. Collect all fields before proceeding:

```
What do you want to add?

  a) New workload (Cloud Run Job + Scheduler + IAM + Secrets)
  b) New foundation resource only (e.g. extra SA, subnet, secret group)
  c) New top-level module pair (foundation + workload)
  d) Something else — describe it

Enter a, b, c, or d:
```

For options a–c, ask follow-up questions to gather:
- `product_name` and `module_name` (if not already set in common.tfvars)
- Any domain-specific variables (e.g. BigQuery dataset/table, cron schedule, Redis size)
- Which environments this applies to (`dev` only, `dev + prd`, all)

For option d, ask the user to describe the resource(s) and intended responsibility, then map it to the closest standard pattern.

### 3. Draft HCL

Generate the full HCL for all required files, strictly following `references/pwd-terraform-standards.md`:

- Apply the naming convention: `${product_name}-${module_name}-${resource_suffix}`
- Place infrastructure resources (APIs, IAM, VPC, storage, secrets) in `modules/foundation/`
- Place compute resources (Cloud Run, Scheduler) in `modules/workload/`
- Wire modules via root `main.tf` — workload receives foundation outputs as explicit vars
- Add `depends_on = [module.foundation]` in the workload module call
- Use `terraform.workspace` for environment-differentiated values (tier, CIDR, log level)
- Add or update `common.tfvars` with shared values; add per-env tfvars for `project_id` and schedules
- Ensure `variables.tf` and `outputs.tf` exist in every module and the root
- Use `for_each` + `toset()` for API enablement and secret groups
- No hardcoded credentials — all sensitive data via Secret Manager
- Add `lifecycle { ignore_changes = [...] }` for CI/CD-managed attributes

Present the full draft as a file tree with the content of each file:

```
Files to create / modify:
─────────────────────────
terraform/
  main.tf               [modified]
  variables.tf          [modified]
  common.tfvars         [modified]
  dev.tfvars            [new]
  modules/
    foundation/
      iam.tf            [new]
      ...
```

Show the complete HCL for each file.

### 4. Confirm with User

```
Does this look correct? (yes / edit / cancel)
```

- `yes` → proceed to Step 5
- `edit` → ask what to change, re-draft, and return to this step
- `cancel` → stop; no files are written

### 5. Execute

On approval:

1. Write all files. For each file:
   - If it is a **new** file, write it in full.
   - If it is a **modified** file, apply only the additions/changes needed — do not overwrite unrelated content.

2. Run `terraform init` from within `./terraform` to download providers and modules.

3. Run `terraform workspace select <env>` (where `<env>` is the workspace identified in Step 1, or `dev` for a new setup) to ensure the correct workspace is active.

4. Confirm completion:

```
Done.

Files written:
  <list of paths>

Workspace ready: <env>
terraform init and workspace selection complete — ready for plan and apply.
```

## Guidelines

- **Never act silently:** Always present a summary and wait for approval before writing files.
- **Respect scope:** Only generate what the user explicitly requested — do not add unrequested resources.
- **Standards are non-negotiable:** All output must conform to `references/pwd-terraform-standards.md`. Never deviate from the naming convention, module separation, or IAM least-privilege pattern.
- **No hardcoded credentials:** Reject any request to inline secrets; redirect to Secret Manager.
- **State is read-only:** Read state files to understand as-is; never modify or delete them.
- **SME skills are required for bootstrap:** `terraform-discoverer` must always be invoked when no `./terraform` folder exists — never skip it. `gcp-project-discoverer` is optional but should always be offered.
- **Discovery baseline drives generation:** Pre-populate Step 2 options and Step 3 HCL from the discovery output. Do not ask the user for information already inferred.

## References

- `references/pwd-terraform-standards.md` — project conventions (naming, module structure, IAM, secrets, workspace config); read during Step 1 after folder detection

## Related Skills

- `terraform-discoverer` — invoked during Step 1 bootstrap to analyse the codebase and propose required GCP resources
- `gcp-project-discoverer` — invoked during Step 1 bootstrap (optional) to cross-reference live GCP infrastructure against the discovery proposal
