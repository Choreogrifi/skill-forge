# GitLab Pipeline Subflow

Handles triggering, monitoring, retrying, and cancelling GitLab CI/CD pipelines using the `glab` CLI.

## Workflow

### 1. Identify Operation

```
Pipeline operation:
  1. View pipeline status for current branch
  2. Trigger a new pipeline
  3. Retry a failed pipeline
  4. Cancel a running pipeline
  5. View pipeline job logs

Enter 1–5:
```

### 2. Gather Details per Operation

**Trigger:** confirm branch, optional variables to pass.

**Retry:** pipeline ID or latest for branch.

**Cancel:** pipeline ID or latest running for branch.

**Logs:** pipeline ID and job name.

### 3. Propose Commands (for write operations)

For trigger, retry, and cancel operations, require explicit approval:

```
Proposed actions:
─────────────────
1. glab ci <trigger|retry|cancel> [options]

⚠ This will <trigger a new pipeline / retry the failed pipeline / cancel the running pipeline>.

Proceed? (yes / cancel)
```

### 4. Execute on Approval (or immediately for read operations)

Run the command. Print pipeline URL and status.

For **view** and **logs** operations (read-only): execute immediately without a confirmation gate.

### 5. Monitor (optional)

After triggering or retrying, ask: `Would you like to watch the pipeline status? (yes / no)`
If yes, run `glab ci status --live` and display updates.

## Guidelines

- Read-only operations (view, logs) do not require confirmation.
- Never cancel a pipeline triggered by another user without explicit justification.
- For `glab ci run` with variables, display the variable names (not values) in the confirmation prompt — never display secret values.
- If a pipeline is required for a protected branch merge, cancelling it will block the MR.
