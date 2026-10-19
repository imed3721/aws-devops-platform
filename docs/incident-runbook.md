# Incident Runbook
## Database high CPU
1. Open CloudWatch.
2. Inspect the database CPU metric.
3. Check whether the increase is sustained.
4. Inspect application errors and request patterns.
5. Check whether a recent change caused the problem.
6. Document the cause and the action taken.
7. Confirm whether the metric returns to a normal level.
## Database low storage
1. Open the RDS console.
2. Confirm the database identifier.
3. Inspect the free storage metric.
4. Check the storage configuration and recent workload.
5. Do not delete or replace the database as an initial reaction.
6. Document the proposed remediation and its cost.
7. Verify that the database remains healthy afterward.
## Terraform drift detected
1. Open the failed GitHub Actions run.
2. Read the Terraform plan.
3. Identify the resource and attribute that differ.
4. Determine whether the difference was intentional.
5. Do not blindly apply the plan.
6. Reconcile the infrastructure through an approved process.
7. Rerun the plan and save the evidence.
