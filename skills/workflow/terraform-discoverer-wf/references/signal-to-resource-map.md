# Signal-to-Resource Map

Maps code signals (file patterns, imports, env vars, config keys) to GCP resource types and the module layer they belong to.

---

## Compute

| Signal | GCP Resource | Module | Confidence |
|---|---|---|---|
| `Dockerfile` present | `google_artifact_registry_repository` | foundation | high |
| `CMD` / `ENTRYPOINT` in Dockerfile, no HTTP server | `google_cloud_run_v2_job` | workload | high |
| HTTP server (express, fastapi, flask, http.ListenAndServe) | `google_cloud_run_v2_service` | workload | high |
| `CRON`, `schedule`, cron expression in config/env | `google_cloud_scheduler_job` | workload | medium |
| Pub/Sub subscription in config | `google_pubsub_subscription` | workload | medium |

---

## Networking

| Signal | GCP Resource | Module | Confidence |
|---|---|---|---|
| Redis client import (`ioredis`, `redis-py`, `go-redis`) | `google_vpc_network` + `google_vpc_access_connector` + `google_redis_instance` | foundation | high |
| Private IP / internal service reference | `google_vpc_network` + `google_compute_subnetwork` | foundation | medium |
| `VPC_CONNECTOR` env var | `google_vpc_access_connector` | foundation | high |
| `REDIS_URL` / `CACHE_URL` env var | `google_redis_instance` | foundation | high |

---

## IAM

| Signal | GCP Resource | Module | Confidence |
|---|---|---|---|
| Any compute resource present | `google_service_account` (worker SA) | foundation | high |
| `google_cloud_scheduler_job` proposed | `google_service_account` (scheduler SA) | foundation | high |
| BigQuery client import | IAM role `roles/bigquery.dataViewer` + `roles/bigquery.jobUser` | foundation | high |
| Secret Manager client import | IAM role `roles/secretmanager.secretAccessor` | foundation | high |
| CI/CD pipeline (Cloud Build detected) | IAM role `roles/run.admin` + `roles/iam.serviceAccountUser` for Cloud Build SA | foundation | medium |

---

## Secrets

| Signal | GCP Resource | Module | Confidence |
|---|---|---|---|
| `.env.example` file | `google_secret_manager_secret` per non-infrastructure env var | foundation | high |
| `process.env.X` / `os.getenv("X")` / `os.Getenv("X")` in source | `google_secret_manager_secret` for each unique `X` | foundation | high |
| `SECRET_MANAGER_SECRET_ID` / `SM_` prefix env var | `google_secret_manager_secret` | foundation | high |
| Database URL / connection string in env | `google_secret_manager_secret` | foundation | high |

---

## Data

| Signal | GCP Resource | Module | Confidence |
|---|---|---|---|
| BigQuery client import (`@google-cloud/bigquery`, `google-cloud-bigquery`, `cloud.google.com/go/bigquery`) | `google_bigquery_dataset` + `google_bigquery_table` | foundation | high |
| `DATASET_ID` / `TABLE_ID` env var | `google_bigquery_dataset` + `google_bigquery_table` | foundation | high |
| Firestore client import | `google_firestore_database` | foundation | medium |
| Cloud Storage client import | `google_storage_bucket` | foundation | medium |
| Pub/Sub publisher import | `google_pubsub_topic` | foundation | medium |

---

## APIs to Enable

Always propose enabling APIs for every resource type present:

| Resource | API |
|---|---|
| Cloud Run | `run.googleapis.com` |
| Artifact Registry | `artifactregistry.googleapis.com` |
| Secret Manager | `secretmanager.googleapis.com` |
| BigQuery | `bigquery.googleapis.com` |
| VPC Access Connector | `vpcaccess.googleapis.com` |
| Memorystore Redis | `redis.googleapis.com` |
| Compute / VPC | `compute.googleapis.com` |
| Cloud Scheduler | `cloudscheduler.googleapis.com` |
| Firestore | `firestore.googleapis.com` |
| Pub/Sub | `pubsub.googleapis.com` |
| Cloud Storage | `storage.googleapis.com` |
