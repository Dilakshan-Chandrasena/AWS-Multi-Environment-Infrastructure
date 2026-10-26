# AWS Multi-Environment Infrastructure and CI/CD

## Overview

This project implements a reusable, Terraform-managed AWS infrastructure for deploying a containerized application across development and production environments.

The solution uses Amazon ECS on AWS Fargate, Amazon ECR, an Application Load Balancer, Amazon VPC networking, CloudWatch monitoring, and GitHub Actions for CI/CD and infrastructure validation.

The implementation emphasizes environment separation, automated security checks, AWS OIDC authentication, controlled production releases, and deployment verification.

## Architecture

The application runs as an ECS Fargate service in private subnets. An internet-facing Application Load Balancer receives external traffic and routes requests to the application through its target group.

Key components:

- **Amazon VPC:** Separate public and private subnets across multiple Availability Zones.
- **Internet Gateway:** Provides internet connectivity for public-facing resources.
- **NAT Gateway:** Enables outbound internet access from private subnets where required.
- **Application Load Balancer:** Routes incoming HTTP traffic to the ECS application.
- **Amazon ECS with Fargate:** Runs the containerized application without managing EC2 worker instances.
- **Amazon ECR:** Stores development and production container images in separate repositories.
- **Amazon CloudWatch:** Collects application logs and infrastructure metrics and supports alarms and dashboards.
- **Amazon S3:** Stores Terraform remote state with encryption and state locking.
- **GitHub Actions:** Automates testing, vulnerability scanning, Terraform validation, planning, and controlled deployment.

Development and production use separate Terraform environments and AWS resources.

## Repository Structure

```text
.
├── app/
│   ├── Dockerfile
│   ├── ecs-task-definition.json
│   ├── requirements.txt
│   ├── requirements-dev.txt
│   └── test_app.py
├── terraform/
│   ├── environments/
│   │   ├── dev/
│   │   └── prod/
│   └── modules/
├── .github/
│   └── workflows/
│       ├── infra-ci-cd.yml
│       ├── app-ci-cd.yml
│       └── app-ci-cd-production.yml
└── README.md
```

## Prerequisites

- Git
- Terraform 1.12.2
- AWS CLI
- Docker
- Python 3.12 for the CI test environment
- An AWS account with appropriately scoped IAM permissions
- A GitHub repository configured for AWS OIDC authentication

The Terraform environments use the AWS region `us-east-1`.

## Infrastructure Management

Terraform configuration is maintained separately for development and production.

### Validate the configuration

From the repository root:

```powershell
terraform fmt -check -recursive terraform/
```

Validate development:

```powershell
terraform -chdir=terraform/environments/dev init -backend=false
terraform -chdir=terraform/environments/dev validate
```

Validate production:

```powershell
terraform -chdir=terraform/environments/prod init -backend=false
terraform -chdir=terraform/environments/prod validate
```

### Review infrastructure changes

After configuring the remote backend and AWS credentials, review a plan before making changes.

```powershell
terraform -chdir=terraform/environments/dev init
terraform -chdir=terraform/environments/dev plan -var-file=terraform.tfvars.example
```

Use the appropriate environment and variable file for production planning.

**Important:** A Terraform plan is not an approval to apply changes. Review resource replacements, deletions, networking changes, and estimated costs before applying anything.

**### Infrastructure CI workflow**

The Infrastructure CI workflow:

1. Checks Terraform formatting.
2. Initializes and validates the development and production configurations.
3. Scans Terraform configuration using Trivy for HIGH and CRITICAL findings.
4. Generates separate development and production Terraform plans on eligible pushes to `main` and manual workflow runs.
5. Uploads each environment's saved plan and readable plan output as a short-lived artifact.
6. Supports an explicitly requested Terraform apply for the selected environment using the corresponding saved plan.

Terraform planning and applying use GitHub Actions OIDC credentials rather than long-lived AWS access keys.

Pull requests run formatting, validation, and security checks but do not run the AWS-backed Terraform plan.

Infrastructure apply operations are restricted to manual workflow dispatches on `main`. Production applies should be protected by the configured GitHub `prod` environment approval rules. Review the saved plan and verify the target environment before approving or applying infrastructure changes.

## Application CI/CD

The Application CI/CD workflow runs when application files or its workflow change.

### Continuous integration

The workflow performs the following checks:

- Installs Python dependencies and runs unit tests.
- Audits Python dependencies using `pip-audit`.
- Builds the Docker image.
- Scans the image using Trivy for HIGH and CRITICAL vulnerabilities.

The Docker build and scan depend on successful unit tests and dependency auditing.

### Development deployment

Publishing and deployment are restricted to successful eligible pushes to `main` and require the GitHub repository variable:

```text
ENABLE_ECR_PUSH=true
```

The deployment workflow:

1. Authenticates to AWS through GitHub OIDC.
2. Builds and pushes an image tagged with the Git commit SHA.
3. Renders and validates the ECS task definition.
4. Registers the task definition with Amazon ECS.
5. Updates the development ECS service.
6. Waits for ECS service stability.
7. Verifies the active task definition and running task counts.

Deployment concurrency is controlled to avoid automatically cancelling an active development deployment.

## Production Release

Production deployment is handled by a separate, manually triggered workflow.

The release process requires:

- A 40-character Git commit SHA identifying the source image in development ECR.
- Explicit confirmation of the production deployment.
- The configured GitHub `prod` environment and its approval requirements.

The workflow:

1. Validates the requested source image tag and retrieves its ECR digest.
2. Promotes the existing image from development ECR to production ECR without rebuilding it.
3. Verifies that the source and destination image digests match.
4. Renders and registers the production ECS task definition.
5. Updates the production ECS service.
6. Waits for service stability and verifies the deployed task definition and running task counts.

Production releases are serialized through a dedicated concurrency group.

This approach helps ensure that the artifact promoted to production is the same image that was built and identified in development.

## Security

The implementation includes the following security controls:

- GitHub Actions authenticates to AWS using OIDC.
- IAM roles provide the AWS permissions required by individual workflows.
- Development and production have separate resources and ECR repositories.
- Terraform configuration is scanned for HIGH and CRITICAL security findings.
- Python dependencies and container images are scanned for vulnerabilities.
- Container images are tagged with immutable commit-SHA identifiers in the CI/CD process.
- Production image promotion includes digest verification.
- ECS tasks run on Fargate in private subnets.
- Terraform state is stored remotely in S3 with encryption and state locking.
- Production deployment requires explicit confirmation and environment approval.

IAM policies should remain restricted to the resources and actions required by each workflow. Secrets and credentials must not be committed to source control.

## Monitoring and Logging

CloudWatch monitoring covers application and infrastructure health, including:

- ECS CPU and memory utilization.
- Running ECS task counts.
- Application Load Balancer HTTP 5xx responses.
- Unhealthy target counts.
- ECS application logs.

CloudWatch dashboards and alarms are configured separately for development and production. ECS Container Insights is enabled, with different log retention periods for the environments.

Email or external notifications should not be assumed unless an alert destination has been configured.

## Operational Considerations

- Review Terraform plans before applying changes.
- Verify ECS health and CloudWatch alarms after a deployment.
- Investigate failed deployments through ECS service events and application logs.
- Keep IAM permissions scoped to the intended environment.
- Protect Terraform state and limit access to plan artifacts.
- Avoid manually changing resources managed by Terraform unless the resulting drift is understood.

## Cost Considerations

AWS resources can incur charges even when application traffic is low. Particular considerations include:

- NAT Gateways and processed data.
- Application Load Balancers.
- ECS Fargate CPU and memory allocation.
- ECR image storage and data transfer.
- CloudWatch log ingestion, storage, dashboards, and alarms.

Review current AWS pricing and the account's remaining credits before running or retaining resources. Remove resources only when they are no longer required and after reviewing the impact on dependent resources and Terraform state.

## Current Scope

The project demonstrates multi-environment Terraform configuration, automated infrastructure checks, application testing and security scanning, controlled container image promotion, ECS deployment verification, and CloudWatch monitoring.

Production deployment should be performed only through the intended release workflow after reviewing the source image, approval requirements, and expected impact.
