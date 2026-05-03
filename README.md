# Opella Infrastructure - Terraform on Azure

Multi-environment Azure infrastructure built with reusable Terraform modules and deployed via GitHub Actions.

---

## Repository Structure
opella-infra/
├── modules/
│   └── vnet/               # Reusable VNET module (shared across environments)
│       ├── main.tf
│       ├── variables.tf
│       ├── outputs.tf
│       └── README.md       # Auto-generated via terraform-docs
├── environments/
│   ├── dev/                # eastus
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   ├── backend.tf
│   │   └── terraform.tfvars
│   └── prod/               # westeurope
│       ├── main.tf
│       ├── variables.tf
│       ├── outputs.tf
│       ├── backend.tf
│       └── terraform.tfvars
├── .github/workflows/
│   └── terraform.yml
├── .pre-commit-config.yaml
└── README.md

---

## What Gets Deployed

Both environments are identical in structure - region, CIDR, and naming are the only differences, driven by `terraform.tfvars` per environment.

### dev - eastus

| Resource | Name | Detail |
|---|---|---|
| Resource Group | `rg-opella-dev-eastus` | Contains all dev resources |
| Virtual Network | `vnet-opella-dev-eastus` | `10.0.0.0/16`, via reusable module |
| Subnet - app | `subnet-app-opella-dev-eastus` | `10.0.1.0/24` |
| Subnet - db | `subnet-db-opella-dev-eastus` | `10.0.2.0/24` |
| NSG - app | `nsg-app-opella-dev-eastus` | Allow 443 inbound, deny all else |
| NSG - db | `nsg-db-opella-dev-eastus` | Allow 1433 from app subnet only |
| Storage Account | `stopelladev<random>` | Private blob container, public access disabled |
| Windows VM | `vm-opella-dev-eastus` | Standard_B1s, app subnet, no public IP |

### prod - westeurope

| Resource | Name | Detail |
|---|---|---|
| Resource Group | `rg-opella-prod-westeurope` | Contains all prod resources |
| Virtual Network | `vnet-opella-prod-westeurope` | `10.1.0.0/16`, via reusable module |
| Subnet - app | `subnet-app-opella-prod-westeurope` | `10.1.1.0/24` |
| Subnet - db | `subnet-db-opella-prod-westeurope` | `10.1.2.0/24` |
| NSG - app | `nsg-app-opella-prod-westeurope` | Allow 443 inbound, deny all else |
| NSG - db | `nsg-db-opella-prod-westeurope` | Allow 1433 from app subnet only |
| Storage Account | `stopellaprod<random>` | Private blob container, public access disabled |
| Windows VM | `vm-opella-prod-westeurope` | Standard_B1s, app subnet, no public IP |

### Outputs (per environment)

| Output | Why it's exposed |
|---|---|
| `vnet_id` | Needed by peering, Private Endpoints, and App Gateway configs |
| `subnet_ids` | Consumed by any resource that needs to attach to a specific subnet |
| `vm_name` | Useful for referencing in scripts, Bastion sessions, and monitoring alerts |
| `storage_account_name` | App config and deployment scripts need this at runtime |
| `resource_group_name` | Required as a reference by any post-deploy tooling or pipelines |

---

## VNET Module

Reusable with no hardcoded values - every environment-specific value is an input.

**Inputs:** `vnet_cidr`, `location`, `subnet_definitions` (map), `tags`, `enable_ddos_protection` (default: false - Standard costs ~$2,944/month, not justified here)

**Outputs:** `vnet_id`, `vnet_name`, `subnet_ids` (name-to-ID map). A map avoids coupling callers to subnet ordering - any downstream resource can reference `subnet_ids["app"]` without caring how many subnets exist.

**Docs:** Auto-generated via terraform-docs on every commit using a pre-commit hook - no manual updates needed.

**Testing:** Out of scope for a 2-4 hour challenge. In production I'd use Terratest - apply, assert VNET CIDR and subnet count, destroy.

---

## CI/CD Pipeline
PR opened

terraform fmt -check
terraform validate
tflint + tfsec
terraform plan (dev + prod) - saved as Actions artifact

Merge to main

Auto-apply dev
Manual approval gate
Apply prod


Plan outputs are under the **Actions** tab - download `terraform-plan-dev` or `terraform-plan-prod` from the latest run.

---

## Design Decisions

**Resource Groups over Subscriptions** - RBAC is simpler at RG scope, tags flow to all child resources for cost tracking, and `terraform destroy` cleans everything atomically. Subscriptions make sense at enterprise scale when you need billing separation or strict policy isolation - unnecessary here.

**Naming:** `{resource}-{project}-{env}-{region}` e.g. `vnet-opella-dev-eastus`

**Tag enforcement:** Every resource gets `Environment`, `Project`, `ManagedBy`, `Owner`. Enforced two ways - Terraform variable validation fails the plan if a tag is missing, and an Azure Policy audit rule catches anything created outside Terraform.

**Auth:** Service Principal + GitHub Secrets for this challenge. Production would use Workload Identity Federation (OIDC) - no long-lived secrets.

**Remote state:** Azure Blob Storage, one container per environment. State locking via native blob lease - no extra infrastructure needed.

| Environment | Storage Account | Container |
|---|---|---|
| dev | `opellatfstate9211` | `dev` |
| prod | `opellatfstate9211` | `prod` |

---

## Code Quality

`terraform fmt` + `terraform validate` + `tflint` + `tfsec` + `pre-commit` hooks. All checks run on every PR and block merge on failure.

---

## GitHub Secrets

The following secrets are configured for Service Principal authentication, used in this challenge due to time constraints and Azure free tier limitations.

`ARM_CLIENT_ID`, `ARM_CLIENT_SECRET`, `ARM_SUBSCRIPTION_ID`, `ARM_TENANT_ID`, `DEV_VM_PASSWORD`, `PROD_VM_PASSWORD`

In production, `ARM_CLIENT_ID` and `ARM_CLIENT_SECRET` would be replaced with OIDC-based Workload Identity Federation - no long-lived secrets stored in GitHub, tokens are short-lived and scoped per workflow run.