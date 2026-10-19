# Architecture Decision Records
## ADR-001: GitHub Actions and OIDC
Decision:
Use GitHub Actions to run infrastructure workflows and OIDC
to obtain temporary AWS credentials.
Reason:
Avoid storing permanent AWS access keys in GitHub.
Trade-off:
The trust policy and IAM permissions must be configured carefully.
## ADR-002: Terraform and S3 state
Decision:
Use Terraform for infrastructure and S3 for remote state.
Reason:
Infrastructure changes are version-controlled and repeatable.
Remote state allows workflows to share the same state.
Trade-off:
The state bucket becomes a critical resource that must be protected.
## ADR-003: Private RDS database
Decision:
Keep the database non-public and restrict ingress to the
application security group.
Reason:
Database access should be limited to authorised application components.
Trade-off:
Private networking requires careful application connectivity design.
## ADR-004: Development availability
Decision:
Start with a single-AZ development database.
Reason:
Keep the learning environment simple and avoid unnecessary
high-availability costs.
Trade-off:
This does not provide the same resilience as a production
multi-AZ deployment.
## ADR-005: Drift detection
Decision:
Run scheduled, plan-only Terraform checks.
Reason:
Detect differences between desired configuration and actual infrastructure.
Trade-off:
A plan with changes requires investigation; it is not automatic proof
of an unauthorised manual change.
