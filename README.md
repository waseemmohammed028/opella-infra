# Opella Infrastructure — Terraform on Azure

Reusable, multi-environment Azure infrastructure provisioned with Terraform and deployed via GitHub Actions.

## Architecture

    opella-infra/
    ├── modules/
    │   └── vnet/              # Reusable VNET module
    │       ├── main.tf
    │       ├── variables.tf
    │       ├── outputs.tf
    │       └── README.md
    ├── environments/
    │   ├── dev/               # Development (eastus)
    │   │   ├── main.tf
    │   │   ├── variables.tf
    │   │   ├── outputs.tf
    │   │   ├── backend.tf
    │   │   └── terraform.tfvars
    │   └── prod/              # Production (westeurope)
    │       ├── main.tf
    │       ├── variables.tf
    │       ├── outputs.tf
    │       ├── backend.tf
    │       └── terraform.tfvars
    ├── .github/
    │   └── workflows/
    │       └── terraform.yml  # CI/CD pipeline
    ├── .gitignore
    └── README.md

## Environments

| Environment | Region     | VNET CIDR   | VM Size      |
|-------------|------------|-------------|--------------|
| dev         | eastus     | 10.0.0.0/16 | Standard_B1s |
| prod        | westeurope | 10.1.0.0/16 | Standard_B1s |

## Resources per environment

| Resource               | Purpose                              |
|------------------------|--------------------------------------|
| Resource Group         | Logical container for all resources  |
| Virtual Network        | Isolated network via reusable module |
| Subnets (app, db)      | Network segmentation                 |
| Network Security Group | Deny-all inbound baseline per subnet |
| Storage Account + Blob | App data storage (private container) |
| Windows VM             | Compute for dev/prod workloads       |

## Release Lifecycle

    Push / PR opened
         │
         ▼
    lint-and-validate  ←─── terraform fmt + validate (both envs)
         │
         ▼
    plan-dev + plan-prod  ←─── terraform plan (artifacts saved)
         │
         ▼
    apply-dev  ←─── auto on merge to main
         │
         ▼
    apply-prod  ←─── manual approval required (GitHub Environment protection)

## Why Resource Groups over Subscriptions for environments?

For this project scale, Resource Groups per environment offer:
- Simpler RBAC — grant access at RG level per team
- Cost tracking via tags per environment
- Easy teardown — delete RG removes everything in that env
- Subscriptions are better suited for enterprise billing isolation or policy boundaries across large teams

## Naming Convention

All resources follow this pattern:

    {prefix}-{project}-{environment}-{region}-{resource-type}

Example: `vnet-opella-dev-eastus`

## Tags enforced on all resources

| Tag         | Value              |
|-------------|--------------------|
| Environment | dev / prod         |
| Project     | opella             |
| ManagedBy   | Terraform          |
| Owner       | DevOps             |

## Remote State

Terraform state is stored remotely in Azure Blob Storage:

| Environment | Storage Account   | Container |
|-------------|-------------------|-----------|
| dev         | opellatfstate9211 | dev       |
| prod        | opellatfstate9211 | prod      |

## Code Quality Tools

| Tool            | Purpose                              |
|-----------------|--------------------------------------|
| terraform fmt   | Auto-format all .tf files            |
| terraform validate | Syntax and config validation      |
| tflint          | Linting for Terraform best practices |
| tfsec           | Security scanning of IaC             |
| pre-commit      | Runs all checks before every commit  |

## Prerequisites

- Terraform >= 1.3.0
- Azure CLI >= 2.83.0
- GitHub Actions secrets configured (see below)

## GitHub Secrets Required

| Secret              | Description                    |
|---------------------|--------------------------------|
| ARM_CLIENT_ID       | Service Principal client ID    |
| ARM_CLIENT_SECRET   | Service Principal secret       |
| ARM_SUBSCRIPTION_ID | Azure subscription ID          |
| ARM_TENANT_ID       | Azure tenant ID                |
| DEV_VM_PASSWORD     | Admin password for dev VM      |
| PROD_VM_PASSWORD    | Admin password for prod VM     |
