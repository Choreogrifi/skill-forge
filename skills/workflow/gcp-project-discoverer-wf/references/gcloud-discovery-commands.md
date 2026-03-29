# GCloud Discovery Commands

Read-only `gcloud` commands to enumerate resources per service area. Always append `--project <project_id>` to every command.

---

## Cloud Run

```bash
gcloud run jobs list --project <project_id> --format="table(name,region,lastModifiedTime)"
gcloud run services list --project <project_id> --format="table(name,region,status.url)"
```

---

## IAM / Service Accounts

```bash
gcloud iam service-accounts list --project <project_id> --format="table(email,displayName,disabled)"
gcloud projects get-iam-policy <project_id> --format=json
```

---

## Networking

```bash
gcloud compute networks list --project <project_id> --format="table(name,autoCreateSubnetworks)"
gcloud compute networks subnets list --project <project_id> --format="table(name,region,ipCidrRange,network)"
gcloud compute routers list --project <project_id> --format="table(name,region,network)"
gcloud beta compute networks vpc-access connectors list --project <project_id> --format="table(name,region,network,ipCidrRange,state)"
```

---

## Artifact Registry

```bash
gcloud artifacts repositories list --project <project_id> --format="table(name,format,location,createTime)"
```

---

## Secret Manager

```bash
gcloud secrets list --project <project_id> --format="table(name,createTime,replication.automatic)"
```

Note: Never retrieve secret values. List names only.

---

## BigQuery

```bash
bq ls --project_id=<project_id> --format=prettyjson
```

For each dataset returned:
```bash
bq ls --project_id=<project_id> <dataset_id>
```

---

## Memorystore (Redis)

```bash
gcloud redis instances list --project <project_id> --format="table(name,region,tier,memorySizeGb,host,port,state)"
```

---

## Cloud Scheduler

```bash
gcloud scheduler jobs list --project <project_id> --format="table(name,schedule,timeZone,state)"
```

---

## Pub/Sub

```bash
gcloud pubsub topics list --project <project_id> --format="table(name)"
gcloud pubsub subscriptions list --project <project_id> --format="table(name,topic,pushConfig.pushEndpoint)"
```

---

## Cloud Storage

```bash
gcloud storage buckets list --project <project_id> --format="table(name,location,storageClass)"
```

---

## Enabled APIs

```bash
gcloud services list --enabled --project <project_id> --format="table(config.name,config.title)"
```

---

## Error Handling

If any command exits non-zero:
- `PERMISSION_DENIED` → log: `<service>: insufficient permissions — skipped`
- `API_NOT_ENABLED` → log: `<service>: API not enabled — skipped`
- Any other error → log: `<service>: <error message> — skipped`

Continue to the next command regardless.
