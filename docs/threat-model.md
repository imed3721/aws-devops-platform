# Threat Model
| Threat | Possible impact | Planned control |
|---|---|---|
| Untrusted workflow requests AWS access | Unauthorised infrastructure changes | Restrict OIDC trust to the intended repositor
| Excessive IAM permissions | Unintended resource changes or deletion | Least-privilege IAM policy |
| Public database exposure | Unauthorised database access | Private RDS configuration and restricted security groups |
| Terraform state exposure | Disclosure of sensitive infrastructure data | S3 access controls, encryption and versioning |
| Manual infrastructure changes | Configuration inconsistency | Scheduled Terraform drift checks |
| Unsafe Terraform apply | Accidental resource replacement or deletion | Plan review and deployment protection |
| Unexpected AWS costs | Unwanted spending | Budget alerts, resource review and teardown |
| Failed database recovery | Data loss or extended downtime | Backup policy and restoration testing |
