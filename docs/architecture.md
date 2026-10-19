# Architecture Overview
## Purpose
A learning platform for deploying and monitoring AWS infrastructure
through GitHub Actions and Terraform.
## Components
- GitHub repository: stores the infrastructure code and documentation.
- GitHub Actions: runs validation, plans, deployment and drift checks.
- AWS IAM and OIDC: authenticate approved workflows using temporary credentials.
- Amazon S3: stores Terraform state with versioning and state locking.
- Amazon VPC: provides network boundaries.
- Private subnets: host the database network placement.
- Security groups: control permitted network traffic.
- Amazon RDS for PostgreSQL: provides the development database.
- Amazon CloudWatch: provides database metric alarms.
## Security
- The database is not publicly accessible.
- Database ingress is restricted to the application security group.
- GitHub workflows do not use long-lived AWS access keys.
- Terraform state is stored remotely and access is restricted.
- Infrastructure changes are reviewed before deployment.
## Reliability limitations
- The database is configured as a single-AZ development resource.
- Recovery procedures must be tested before the platform is used for important data.
- The initial configuration is not a production high-availability design.
## Cost limitations
- Live resources are created only after a pricing review.
- RDS, Secrets Manager, CloudWatch and other services may incur charges.
- The state bucket and monitoring resources also require cost review.
## Outstanding work
- Implement and test a real application-to-database integration.
- Add notification delivery for important alarms.
- Test database restoration.
- Refine IAM permissions to least privilege.
- Document the results of drift experiments.
