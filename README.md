# AWS DevOps Platform — Terraform & GitHub Actions

**Infrastructure as Code · CI/CD Automation · AWS Networking · Drift Detection · Secure Cloud Operations**

An AWS DevOps portfolio project demonstrating the end-to-end lifecycle of cloud infrastructure: provisioning, automated deployment, monitoring, drift detection, troubleshooting, and controlled teardown.

Built with Terraform, AWS, and GitHub Actions, this project demonstrates Infrastructure as Code (IaC), secure OIDC authentication, remote state management, private database networking, operational monitoring, and infrastructure lifecycle management.

**Technology stack**

![AWS](https://img.shields.io/badge/AWS-Cloud%20Infrastructure-orange)
![Terraform](https://img.shields.io/badge/Terraform-Infrastructure%20as%20Code-7B42BC)
![GitHub Actions](https://img.shields.io/badge/GitHub%20Actions-CI%2FCD-2088FF)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-Database-4169E1)
![OIDC](https://img.shields.io/badge/OIDC-Federated%20Authentication-green)

**Repository:** [imed3721/aws-devops-platform](https://github.com/imed3721/aws-devops-platform)

---

## Table of Contents

- [1. Project Overview](#1-project-overview)
- [2. Project Objectives](#2-project-objectives)
- [3. Architecture](#3-architecture)
- [4. AWS Infrastructure](#4-aws-infrastructure)
- [5. Security and Access Control](#5-security-and-access-control)
- [6. CI/CD and Terraform Workflows](#6-cicd-and-terraform-workflows)
- [7. Infrastructure Drift Detection](#7-infrastructure-drift-detection)
- [8. Cleanup and Final State](#8-cleanup-and-final-state)
- [9. Repository Structure](#9-repository-structure)
- [10. Project Evidence and Screenshots](#10-project-evidence-and-screenshots)
- [11. Key Skills Demonstrated](#11-key-skills-demonstrated)
- [12. Challenges and Lessons Learned](#12-challenges-and-lessons-learned)
- [13. Cost Management](#13-cost-management)
- [14. Future Improvements](#14-future-improvements)

## 1. Project Overview

This project demonstrates how AWS infrastructure can be defined, deployed, monitored, and managed using Terraform and GitHub Actions rather than relying entirely on manual configuration through the AWS Management Console.

Terraform defines the infrastructure as code, while GitHub Actions automates key stages of the infrastructure lifecycle, including validation, planning, deployment, and destruction.

GitHub Actions authenticates to AWS using OpenID Connect (OIDC) and an IAM role, avoiding the need to store long-lived AWS access keys in GitHub for workflow authentication.

The project also explores infrastructure drift: identifying differences between the intended Terraform configuration and the actual AWS environment, then reconciling those differences.

Finally, a manually triggered destruction workflow demonstrates how development infrastructure can be removed in a controlled manner.

## 2. Project Objectives

The main objectives of this project are to:

- Define AWS infrastructure using Terraform and version control.
- Automate Terraform validation, planning, and deployment with GitHub Actions.
- Configure federated AWS authentication using GitHub OIDC and IAM.
- Manage Terraform state remotely using Amazon S3 and S3 lock-file support.
- Deploy a private Amazon RDS for PostgreSQL database.
- Restrict database access using security groups.
- Configure CloudWatch alarms for database CPU utilisation and available storage.
- Introduce, detect, and reconcile infrastructure drift.
- Implement a manually triggered Terraform destruction workflow.
- Verify resource cleanup while retaining the Terraform state backend.

## 3. Architecture

The architecture connects the GitHub Actions automation workflow to AWS through federated authentication. Terraform manages the infrastructure and stores its state remotely in Amazon S3.

```mermaid
flowchart TD
    A[Developer] --> B[GitHub Repository]
    B --> C[GitHub Actions]

    C --> D[Terraform Validation]
    C --> E[Terraform Plan]
    C --> F[Terraform Apply]
    C --> G[Terraform Destroy]

    D --> H[GitHub OIDC]
    E --> H
    F --> H
    G --> H

    H --> I[AWS IAM Role]
    I --> J[Terraform AWS Provider]

    J --> K[Amazon VPC]
    K --> L[Private Subnet A]
    K --> M[Private Subnet B]

    L --> N[Security Groups]
    M --> N
    N --> O[Amazon RDS PostgreSQL]

    O --> P[CloudWatch Alarms]
    O --> Q[AWS Secrets Manager]

    J <--> R[Amazon S3 Remote State]
```

The diagram represents the project design and automation flow. Screenshots in Section 10 provide evidence of the infrastructure and workflow stages.

## 4. AWS Infrastructure

Terraform manages the AWS resources required for the development environment.

| Component | Purpose |
|---|---|
| Amazon VPC | Provides an isolated virtual network. |
| Private subnets | Provide network placement for private resources. |
| Security groups | Control permitted network traffic. |
| Amazon RDS for PostgreSQL | Provides a managed relational database. |
| RDS DB subnet group | Defines the subnets available to the database. |
| Amazon CloudWatch | Monitors database CPU utilisation and free storage. |
| AWS Secrets Manager | Integrates with RDS to manage the master password. |
| Amazon S3 | Stores Terraform state and the state lock file. |

### Network configuration

The development VPC uses the `10.20.0.0/16` IPv4 CIDR range.

Two subnets are configured:

- `10.20.1.0/24`
- `10.20.2.0/24`

Security groups control communication between the relevant infrastructure components.

### Database configuration

The project uses Amazon RDS for PostgreSQL with the following configuration:

| Setting | Configuration |
|---|---|
| Database engine | PostgreSQL |
| Instance class | `db.t3.micro` |
| Public accessibility | Disabled |
| Storage encryption | Enabled |
| Master password | Managed through AWS Secrets Manager |
| Network placement | Configured RDS DB subnet group |

Inbound PostgreSQL traffic on port `5432` is restricted to the application security group rather than being open to unrestricted inbound access.

### Monitoring and alerting

Two CloudWatch alarms are configured to monitor the database:

| Alarm | Threshold | Purpose |
|---|---:|---|
| High CPU utilisation | 80% | Identifies elevated database CPU utilisation. |
| Low free storage | 2 GiB | Identifies when available database storage falls below the configured threshold. |

These alarms demonstrate how monitoring resources can be defined and managed alongside the infrastructure they monitor.

## 5. Security and Access Control

Security is addressed through network restrictions, federated authentication, IAM permissions, encrypted database storage, and remote state management.

### GitHub Actions OIDC

GitHub Actions assumes an AWS IAM role through OpenID Connect. This avoids the need for long-lived AWS access keys in GitHub workflow configuration.

The IAM role trust policy restricts access to the configured repository context, including the authorised branch and deployment environment.

### IAM permissions

The workflow role has permissions for the AWS operations required by Terraform, including:

- VPC, subnet, security group, and network interface discovery.
- RDS instance and subnet group management.
- CloudWatch alarm management.
- Amazon S3 state access and lock-file operations.
- Supporting permissions required by the configured deployment.

The role must have sufficient permissions for both provisioning and destruction. The initial teardown attempt exposed a missing `ec2:DescribeNetworkInterfaces` permission, highlighting the importance of testing the full infrastructure lifecycle.

IAM permissions should be scoped as narrowly as practical and updated based on the actual requirements of the workflows.

### Remote Terraform state

The Terraform backend uses Amazon S3 with the following configuration:

| Setting | Value |
|---|---|
| Bucket | `aws-devops-state-demi` |
| State key | `aws-devops-platform/dev/terraform.tfstate` |
| State locking | S3 lock file enabled |

Remote state allows Terraform to track managed resources between workflow runs. The state backend is retained after development infrastructure is destroyed so that the project can be managed again without recreating the backend.

## 6. CI/CD and Terraform Workflows

GitHub Actions automates the Terraform lifecycle through separate workflows.

| Workflow | Responsibility |
|---|---|
| Terraform Validation | Checks the Terraform configuration. |
| Terraform Plan | Previews proposed infrastructure changes. |
| Terraform Apply | Creates or updates infrastructure. |
| Terraform Destroy | Manually initiates infrastructure removal. |

### Deployment lifecycle

The automated workflow follows these stages:

1. GitHub Actions starts the selected workflow.
2. The repository is checked out.
3. Terraform version `1.10.5` is installed.
4. GitHub Actions authenticates to AWS through OIDC and the configured IAM role.
5. Terraform initialises using the Amazon S3 backend.
6. The workflow executes the relevant validation, planning, deployment, or destruction operation.
7. Workflow logs provide evidence of the outcome.

### Validation

Terraform validation helps identify configuration issues before changes are deployed.

### Plan

Terraform plan previews proposed changes, helping identify unexpected resource additions, modifications, or deletions before execution.

### Apply

Terraform apply creates or updates resources according to the Terraform configuration and the selected plan.

### Destroy

The Terraform Destroy workflow is manually triggered and requires the exact confirmation text `DESTROY`.

The workflow initialises Terraform, previews the resources proposed for removal, and executes the destruction operation.

The confirmation requirement helps reduce accidental execution, but destructive changes should still be reviewed carefully. GitHub environment protection and required reviewers can provide additional safeguards when configured.

## 7. Infrastructure Drift Detection

Infrastructure drift occurs when the actual AWS environment differs from the intended Terraform configuration.

This project demonstrates a controlled drift-testing process to show how changes made outside Terraform can be identified and reconciled.

### Drift testing process

1. **Introduce drift:** Make a controlled change to a managed AWS resource outside Terraform.
2. **Detect drift:** Run Terraform plan and inspect the differences between the actual and expected configuration.
3. **Reconcile drift:** Apply the intended configuration when appropriate and verify the resulting state.

The screenshots in Section D document these stages.

Drift detection is important because manual changes can introduce configuration inconsistencies, weaken security controls, and make future deployments less predictable.

Terraform plans should be reviewed before application. The detected changes depend on the resource, provider behaviour, state, and configuration, so the plan should be treated as a reviewable proposal rather than automatically applied without inspection.

## 8. Cleanup and Final State

The project includes a dedicated GitHub Actions workflow for removing the development infrastructure.

The teardown process demonstrates:

- Manual workflow triggering.
- Explicit confirmation before destructive execution.
- Terraform destroy planning and execution.
- Troubleshooting IAM permissions and resource dependencies.
- Verification of the final infrastructure state.
- Retention of the remote Terraform state backend.

### Teardown troubleshooting

During the initial destroy attempt, deletion of the remaining network resources failed because the workflow role lacked `ec2:DescribeNetworkInterfaces`.

The IAM policy was updated to address the missing permission.

This illustrates an important operational lesson: successfully provisioning infrastructure does not guarantee that the same role can destroy every resource. Terraform may need additional permissions to discover dependencies and remove resources in the correct order.

### Final-state verification

The successful destroy run and AWS Console checks should be used to verify cleanup.

Resources shown in the deployment screenshots represent the environment when it was running; they should not be interpreted as proof that those resources still exist after teardown.

The Terraform state bucket is retained separately from the development infrastructure. The destroy workflow should not be treated as confirmation that all potentially billable AWS resources, backups, or separately managed resources have been removed.

## 9. Repository Structure

The repository contains the Terraform configuration, GitHub Actions workflows, screenshots, and project documentation.

```text
aws-devops-platform/
├── .github/
│   └── workflows/
│       ├── terraform-validate.yml
│       ├── terraform-plan.yml
│       ├── terraform-apply.yml
│       └── terraform-destroy.yml
├── infra/
│   └── Terraform configuration and backend files
├── screenshots/
│   └── Project evidence images
└── README.md
```

The screenshot directory contains evidence organised into five groups: repository and code, CI/CD deployment, AWS infrastructure, infrastructure drift, and cleanup.

## 10. Project Evidence and Screenshots

The following screenshots document the project implementation from source code through deployment, drift testing, and teardown.

### A. GitHub Repository and Terraform Code

This section demonstrates the repository structure and Terraform implementation.

**Repository structure**

Shows the repository and its project files.

![GitHub repository structure](https://github.com/imed3721/aws-devops-platform/blob/82a12a6f044c8fb7f2e47a6c93947f5dcb08ed9a/screenshots/Screenshot%202026-10-19%20154158.png)

**Terraform configuration**

Shows the Terraform code used to define and manage the infrastructure.

![Terraform configuration 1](https://github.com/imed3721/aws-devops-platform/blob/82a12a6f044c8fb7f2e47a6c93947f5dcb08ed9a/screenshots/Screenshot%202026-10-19%20154235.png)

![Terraform configuration 2](https://github.com/imed3721/aws-devops-platform/blob/82a12a6f044c8fb7f2e47a6c93947f5dcb08ed9a/screenshots/Screenshot%202026-10-19%20154245.png)

![Terraform configuration 3](https://github.com/imed3721/aws-devops-platform/blob/82a12a6f044c8fb7f2e47a6c93947f5dcb08ed9a/screenshots/Screenshot%202026-10-19%20154251.png)

![Terraform configuration 4](https://github.com/imed3721/aws-devops-platform/blob/82a12a6f044c8fb7f2e47a6c93947f5dcb08ed9a/screenshots/Screenshot%202026-10-19%20154318.png)

![Terraform configuration 5](https://github.com/imed3721/aws-devops-platform/blob/82a12a6f044c8fb7f2e47a6c93947f5dcb08ed9a/screenshots/Screenshot%202026-10-19%20154450.png)

### B. CI/CD and Terraform Deployment

This section demonstrates automated validation, planning, and deployment using GitHub Actions.

**Terraform validation**

![Terraform validation workflow 1](https://github.com/imed3721/aws-devops-platform/blob/f02babf3f5bdd8fe97a1aa36cba95f70b72dbe39/screenshots/Screenshot%202026-10-19%20154631.png)

![Terraform validation workflow 2](https://github.com/imed3721/aws-devops-platform/blob/f02babf3f5bdd8fe97a1aa36cba95f70b72dbe39/screenshots/Screenshot%202026-10-19%20154653.png)

![Terraform validation workflow 3](https://github.com/imed3721/aws-devops-platform/blob/d7086efc93323e58dab75338e543526275225e78/screenshots/Screenshot%202026-10-19%20165004.png)

![Terraform validation workflow 4](https://github.com/imed3721/aws-devops-platform/blob/d7086efc93323e58dab75338e543526275225e78/screenshots/Screenshot%202026-10-19%20165020.png)

![Terraform validation workflow 5](https://github.com/imed3721/aws-devops-platform/blob/d7086efc93323e58dab75338e543526275225e78/screenshots/Screenshot%202026-10-19%20165028.png)

![Terraform validation workflow 6](https://github.com/imed3721/aws-devops-platform/blob/d7086efc93323e58dab75338e543526275225e78/screenshots/Screenshot%202026-10-19%20165035.png)

**Terraform plan**

![Terraform plan 1](https://github.com/imed3721/aws-devops-platform/blob/f02babf3f5bdd8fe97a1aa36cba95f70b72dbe39/screenshots/Screenshot%202026-10-19%20154714.png)

![Terraform plan 2](https://github.com/imed3721/aws-devops-platform/blob/f02babf3f5bdd8fe97a1aa36cba95f70b72dbe39/screenshots/Screenshot%202026-10-19%20154724.png)

![Terraform plan 3](https://github.com/imed3721/aws-devops-platform/blob/d7086efc93323e58dab75338e543526275225e78/screenshots/Screenshot%202026-10-19%20165104.png)

![Terraform plan 4](https://github.com/imed3721/aws-devops-platform/blob/d7086efc93323e58dab75338e543526275225e78/screenshots/Screenshot%202026-10-19%20165112.png)

**Terraform apply**

![Terraform apply 1](https://github.com/imed3721/aws-devops-platform/blob/f02babf3f5bdd8fe97a1aa36cba95f70b72dbe39/screenshots/Screenshot%202026-10-19%20155245.png)

![Terraform apply 2](https://github.com/imed3721/aws-devops-platform/blob/f02babf3f5bdd8fe97a1aa36cba95f70b72dbe39/screenshots/Screenshot%202026-10-19%20155258.png)

![Terraform apply 3](https://github.com/imed3721/aws-devops-platform/blob/d7086efc93323e58dab75338e543526275225e78/screenshots/Screenshot%202026-10-19%20165139.png)

![Terraform apply 4](https://github.com/imed3721/aws-devops-platform/blob/d7086efc93323e58dab75338e543526275225e78/screenshots/Screenshot%202026-10-19%20165147.png)

### C. Live AWS Infrastructure

These screenshots document the AWS infrastructure during the deployment stage.

**VPC and subnets**

![AWS VPC](https://github.com/imed3721/aws-devops-platform/blob/27470aa6da46e12fad990d7aa90b38a12eaeda15/screenshots/Screenshot%202026-10-19%20155937.png)

![AWS subnets](https://github.com/imed3721/aws-devops-platform/blob/27470aa6da46e12fad990d7aa90b38a12eaeda15/screenshots/Screenshot%202026-10-19%20160013.png)

**Amazon RDS**

![Amazon RDS configuration](https://github.com/imed3721/aws-devops-platform/blob/27470aa6da46e12fad990d7aa90b38a12eaeda15/screenshots/Screenshot%202026-10-19%20160043.png)

**CloudWatch alarms**

![CloudWatch database alarms](https://github.com/imed3721/aws-devops-platform/blob/27470aa6da46e12fad990d7aa90b38a12eaeda15/screenshots/Screenshot%202026-10-19%20165826.png)

### D. Infrastructure Drift

This section documents the drift-testing process, from introducing a controlled change to detecting and reconciling it.

**Drift introduced**

![Infrastructure drift evidence 1](https://github.com/imed3721/aws-devops-platform/blob/82502cd517059ee0a3618ec6db8bec6caa588640/screenshots/Screenshot%202026-10-19%20145122.png)

![Infrastructure drift evidence 2](https://github.com/imed3721/aws-devops-platform/blob/82502cd517059ee0a3618ec6db8bec6caa588640/screenshots/Screenshot%202026-10-19%20145217.png)

![Infrastructure drift evidence 3](https://github.com/imed3721/aws-devops-platform/blob/82502cd517059ee0a3618ec6db8bec6caa588640/screenshots/Screenshot%202026-10-19%20145221.png)

![Infrastructure drift evidence 4](https://github.com/imed3721/aws-devops-platform/blob/82502cd517059ee0a3618ec6db8bec6caa588640/screenshots/Screenshot%202026-10-19%20145226.png)

**Drift detected by Terraform**

![Terraform drift detection 1](https://github.com/imed3721/aws-devops-platform/blob/82502cd517059ee0a3618ec6db8bec6caa588640/screenshots/Screenshot%202026-10-19%20150137.png)

![Terraform drift detection 2](https://github.com/imed3721/aws-devops-platform/blob/82502cd517059ee0a3618ec6db8bec6caa588640/screenshots/Screenshot%202026-10-19%20150144.png)

**Drift remediation**

![Infrastructure drift remediation 1](https://github.com/imed3721/aws-devops-platform/blob/82502cd517059ee0a3618ec6db8bec6caa588640/screenshots/Screenshot%202026-10-19%20150328.png)

![Infrastructure drift remediation 2](https://github.com/imed3721/aws-devops-platform/blob/82502cd517059ee0a3618ec6db8bec6caa588640/screenshots/Screenshot%202026-10-19%20150333.png)

![Infrastructure drift remediation 3](https://github.com/imed3721/aws-devops-platform/blob/82502cd517059ee0a3618ec6db8bec6caa588640/screenshots/Screenshot%202026-10-19%20150710.png)

![Infrastructure drift remediation 4](https://github.com/imed3721/aws-devops-platform/blob/82502cd517059ee0a3618ec6db8bec6caa588640/screenshots/Screenshot%202026-10-19%20150824.png)

### E. Cleanup and Final State

This section documents the manual destruction workflow and the final-state evidence.

**Terraform Destroy workflow**

![Terraform destroy workflow 1](https://github.com/imed3721/aws-devops-platform/blob/2c5641eacfeea45dbc88bc32b86d8dfedfde3be6/screenshots/Screenshot%202026-10-19%20160526.png)

![Terraform destroy workflow 2](https://github.com/imed3721/aws-devops-platform/blob/2c5641eacfeea45dbc88bc32b86d8dfedfde3be6/screenshots/Screenshot%202026-10-19%20160535.png)

**Terraform destroy execution**

![Terraform destroy result](https://github.com/imed3721/aws-devops-platform/blob/2c5641eacfeea45dbc88bc32b86d8dfedfde3be6/screenshots/Screenshot%202026-10-19%20161553.png)

**AWS cleanup verification**

![AWS cleanup verification 1](https://github.com/imed3721/aws-devops-platform/blob/2c5641eacfeea45dbc88bc32b86d8dfedfde3be6/screenshots/Screenshot%202026-10-19%20162347.png)

![AWS cleanup verification 2](https://github.com/imed3721/aws-devops-platform/blob/2c5641eacfeea45dbc88bc32b86d8dfedfde3be6/screenshots/Screenshot%202026-10-19%20162403.png)

![AWS cleanup verification 3](https://github.com/imed3721/aws-devops-platform/blob/2c5641eacfeea45dbc88bc32b86d8dfedfde3be6/screenshots/Screenshot%202026-10-19%20162424.png)

## 11. Key Skills Demonstrated

This project demonstrates practical experience with:

- **Infrastructure as Code:** Defining and managing AWS resources using Terraform.
- **CI/CD automation:** Building GitHub Actions workflows for infrastructure operations.
- **Federated authentication:** Configuring GitHub OIDC and AWS IAM role assumption.
- **AWS networking:** Creating VPCs, subnets, and security groups.
- **Database infrastructure:** Configuring Amazon RDS for PostgreSQL.
- **Cloud security:** Restricting database access and enabling storage encryption.
- **Remote state management:** Using Amazon S3 and S3 lock-file support.
- **Monitoring:** Configuring CloudWatch database alarms.
- **Drift management:** Identifying and reconciling infrastructure differences.
- **Operational troubleshooting:** Investigating IAM permission errors and resource dependencies.
- **Lifecycle management:** Planning, deploying, and destroying development infrastructure.
- **Technical documentation:** Recording implementation and verification evidence.

## 12. Challenges and Lessons Learned

### IAM permissions must cover the complete lifecycle

The initial teardown attempt exposed a missing network-interface discovery permission. Fixing the specific permission highlighted the importance of testing both provisioning and destruction with the intended IAM role.

### Remote state supports consistent infrastructure management

Terraform state records the resources Terraform manages. Retaining the remote backend allows future workflow runs to use the existing state rather than losing track of managed resources.

### Network restrictions reduce exposure

Private database placement and security group rules help limit access to the database to the intended network sources.

### Destructive operations require deliberate controls

A manually triggered destroy workflow provides an explicit action before removing resources. Reviewing the proposed changes and verifying the final result remain essential.

### Evidence improves technical communication

Organising screenshots into five groups makes the implementation easier to review and demonstrates the relationship between code, automation, AWS resources, drift testing, and cleanup.

## 13. Cost Management

AWS resources may incur charges while running, particularly managed database instances and associated storage.

The project includes a Terraform Destroy workflow to support cleanup when the development environment is no longer required.

After teardown:

- Confirm the destroy workflow completes successfully.
- Verify that the intended VPC, subnets, security groups, RDS resources, and CloudWatch alarms have been removed.
- Check for separately managed resources, backups, or other remaining billable services.
- Retain the S3 state backend unless you deliberately decide to decommission it.

Destroying the resources managed by Terraform does not automatically guarantee that every potentially billable resource in the AWS account has been removed.

## 14. Future Improvements

Potential improvements include:

- Add Terraform formatting and validation checks to pull requests.
- Introduce separate development and production environments.
- Configure required reviewers for sensitive deployment and destruction workflows.
- Refine IAM permissions to follow least-privilege principles.
- Add automated security scanning for Terraform configuration.
- Expand monitoring, logging, and alert notifications.
- Improve teardown safety by saving and reviewing a specific destroy plan before execution.
- Add automated infrastructure tests and recovery documentation.

---

## Conclusion

The AWS DevOps Platform demonstrates an end-to-end approach to managing cloud infrastructure through code and automated workflows.

By combining Terraform, GitHub Actions, OIDC authentication, private AWS networking, database monitoring, drift detection, and controlled teardown, the project showcases practical DevOps techniques across the infrastructure lifecycle.

The five evidence sections document the implementation from source code through deployment, drift testing, and cleanup, providing a clear record of the technical decisions and operational challenges involved.

**Explore the project:** [github.com/imed3721/aws-devops-platform](https://github.com/imed3721/aws-devops-platform)
