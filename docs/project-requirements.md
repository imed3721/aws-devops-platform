# AWS DevOps Platform — Project Requirements
## Purpose
Build a small, secure AWS platform using Terraform and GitHub Actions.
## Learning goals
- Understand AWS identity and permissions.
- Authenticate GitHub Actions to AWS using OIDC.
- Manage infrastructure using Terraform.
- Store Terraform state remotely in S3.
- Use a private Amazon RDS PostgreSQL database.
- Monitor infrastructure using Amazon CloudWatch.
- Detect and investigate infrastructure drift.
- Document architecture, risks, costs and recovery procedures.
## Constraints
- No local terminal or locally installed tools.
- No AWS CloudShell.
- No Helm or AWS App Runner.
- Use browser-based interfaces and GitHub-hosted runners.
- Avoid charges wherever possible.
- Do not store credentials or sensitive information in Git.
## Security requirements
- No permanent AWS access keys in GitHub.
- Restrict OIDC trust to the intended repository and branch.
- Use least-privilege IAM permissions.
- - Keep the database private.
- Review Terraform plans before applying changes.
- Protect Terraform state.
## Operational requirements
- Validate infrastructure configuration automatically.
- Detect and report unexpected infrastructure changes.
- Document safe remediation and recovery.
- Check resource costs and remove resources when finished.
## Limitations
This is a learning environment, not a production system.
Any live AWS deployment must be cost-checked first.
