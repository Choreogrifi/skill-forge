# Signal-to-Resource Map

Maps code signals (file patterns, imports, env vars, config keys) to cloud resource categories and the module layer they belong to.

> **Customise this file** with your cloud provider's actual Terraform resource names.
> Replace the generic `<provider>_*` patterns with your specific provider prefix
> (e.g. `google_`, `aws_`, `azurerm_`).

---

## Compute

| Signal | Resource Category | Terraform Resource Pattern | Module | Confidence |
|---|---|---|---|---|
| `Dockerfile` present | Container registry | `<provider>_container_registry` | foundation | high |
| `CMD` / `ENTRYPOINT` in Dockerfile, no HTTP server | Batch job / worker | `<provider>_job` or `<provider>_batch_job` | workload | high |
| HTTP server (express, fastapi, flask, http.ListenAndServe) | Web service / API | `<provider>_service` or `<provider>_function` | workload | high |
| `CRON`, `schedule`, cron expression in config/env | Cron scheduler | `<provider>_scheduler_job` | workload | medium |
| Message queue subscription in config | Message consumer | `<provider>_subscription` | workload | medium |

---

## Networking

| Signal | Resource Category | Terraform Resource Pattern | Module | Confidence |
|---|---|---|---|---|
| Cache client import (`ioredis`, `redis-py`, `go-redis`) | VPC + cache instance | `<provider>_vpc_network` + `<provider>_cache_instance` | foundation | high |
| Private IP / internal service reference | VPC network | `<provider>_vpc_network` + `<provider>_subnet` | foundation | medium |
| `VPC_CONNECTOR` / `PRIVATE_SUBNET` env var | VPC connector | `<provider>_vpc_connector` | foundation | high |
| `REDIS_URL` / `CACHE_URL` env var | Cache instance | `<provider>_cache_instance` | foundation | high |

---

## IAM

| Signal | Resource Category | Terraform Resource Pattern | Module | Confidence |
|---|---|---|---|---|
| Any compute resource present | Worker service account | `<provider>_service_account` (worker) | foundation | high |
| Scheduler resource proposed | Scheduler service account | `<provider>_service_account` (scheduler) | foundation | high |
| Database client import | DB read role | `<provider>_iam_binding` (narrow read role) | foundation | high |
| Secrets manager client import | Secret read role | `<provider>_iam_binding` (secret accessor) | foundation | high |
| CI/CD pipeline detected | CI/CD deploy role | `<provider>_iam_binding` (deploy + SA user) | foundation | medium |

---

## Secrets

| Signal | Resource Category | Terraform Resource Pattern | Module | Confidence |
|---|---|---|---|---|
| `.env.example` file | Secret per non-infra env var | `<provider>_secret` | foundation | high |
| `process.env.X` / `os.getenv("X")` in source | Secret per unique key | `<provider>_secret` | foundation | high |
| `SECRET_` / `SM_` prefix env var | Secret | `<provider>_secret` | foundation | high |
| Database URL / connection string in env | Secret | `<provider>_secret` | foundation | high |

---

## Data

| Signal | Resource Category | Terraform Resource Pattern | Module | Confidence |
|---|---|---|---|---|
| Data warehouse client import (BigQuery, Redshift, Snowflake) | Dataset + table | `<provider>_dataset` + `<provider>_table` | foundation | high |
| `DATASET_ID` / `TABLE_ID` env var | Dataset + table | `<provider>_dataset` + `<provider>_table` | foundation | high |
| Document DB client import (Firestore, DynamoDB, CosmosDB) | Document database | `<provider>_database` | foundation | medium |
| Object storage client import (S3, GCS, Azure Blob) | Storage bucket | `<provider>_bucket` | foundation | medium |
| Message queue publisher import (Pub/Sub, SQS, Service Bus) | Message topic | `<provider>_topic` | foundation | medium |

---

## Services to Enable

List provider-specific service enablement resources required for each resource category:

| Resource Category | Terraform Resource Pattern |
|---|---|
| Container workloads | `<provider>_api_service { service = "container-api" }` |
| Secrets manager | `<provider>_api_service { service = "secretmanager-api" }` |
| Data warehouse | `<provider>_api_service { service = "bigquery-api" }` |
| Cache | `<provider>_api_service { service = "cache-api" }` |
| Scheduler | `<provider>_api_service { service = "scheduler-api" }` |
| Object storage | `<provider>_api_service { service = "storage-api" }` |
| Messaging | `<provider>_api_service { service = "messaging-api" }` |
