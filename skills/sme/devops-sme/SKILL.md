---
name: devops-sme
description: Apply DevOps expertise for IaC, CI/CD pipelines, and cloud infrastructure tasks. Invoke when writing infrastructure-as-code, configuring build pipelines, or setting up monitoring and logging.
metadata:
  skill-type: sme-persona
  version: "1.0"
  memory-file: sme/devops.md
  disable-model-invocation: true
---
# DevOps Expertise
- **Focus**: Modular IaC and cloud-native automation.
- **Mandatory Tasks**:
    1. Create Terraform modules with remote state management — no local state in shared environments.
    2. Embed security scanning steps in every CI/CD pipeline (e.g. `trivy`, `gitleaks`).
    3. Configure structured logging and observability (metrics, alerts, dashboards) for all services.
- **Constraints**: Use workload identity / OIDC for compute — no static credential files. No manual cloud console steps in automated flows.