# test-ghskills — Personal Blog

A Vue.js SPA served from nginx, containerised, and hosted on Azure Container Apps. Infrastructure is managed with Terraform; CI/CD runs on GitHub Actions with OIDC authentication.

## Prerequisites

| Tool | Version |
|------|---------|
| Node.js | 22+ |
| Terraform | 1.9+ |
| Azure CLI | latest |
| Docker (local builds only) | — |

### Azure bootstrap

Before the first `terraform apply` you need:

1. **Terraform remote state** — an Azure Storage Account + container for `.tfstate`. Fill in `infra/environments/production/backend.hcl` with the details.
2. **OIDC federated credential** — create an Entra app registration and add a federated credential for subject `repo:pmsousa/test-ghskills:ref:refs/heads/main` (for apply) and `repo:pmsousa/test-ghskills:pull_request` (for plan). Assign the service principal `Contributor` on the subscription and `AcrPush` on the ACR once created.

### GitHub repository variables & secrets

Go to **Settings → Secrets and variables → Actions** and add:

| Kind | Name | Example value |
|------|------|---------------|
| Secret | `AZURE_CLIENT_ID` | `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx` |
| Secret | `AZURE_TENANT_ID` | `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx` |
| Secret | `AZURE_SUBSCRIPTION_ID` | `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx` |
| Variable | `ACR_NAME` | `crblogproductionwesteu` |
| Variable | `ACR_LOGIN_SERVER` | `crblogproductionwesteu.azurecr.io` |
| Variable | `CONTAINER_APP_NAME` | `ca-blog-production-westeu` |
| Variable | `RESOURCE_GROUP` | `rg-blog-production-westeu` |

Also create a **GitHub Environment** named `production` with required reviewers or deployment branch rules as desired.

## Getting Started

```powershell
# Install Vue app dependencies
cd src
npm install

# Local dev server
npm run dev
```

## Infrastructure

```powershell
cd infra

# Init with production backend
terraform init -backend-config=environments/production/backend.hcl

# Plan
terraform plan -var-file=environments/production/terraform.tfvars

# Apply
terraform apply -var-file=environments/production/terraform.tfvars
```

State is stored in Azure Blob Storage (`tfstate` container, key `blog/production.tfstate`).

## CI/CD

| Workflow | Trigger | Action |
|----------|---------|--------|
| `ci.yml` | PR to `main` | `npm ci` + build + docker build (no push) |
| `cd.yml` | Push to `main` (non-infra paths) | `az acr build` → `az containerapp update` |
| `terraform.yml` | PR/push to `main` on `infra/**` changes | plan on PR, apply on merge |

## Contributing

- Branch naming: `feat/`, `fix/`, or `chore/` prefix
- Commit messages follow [Conventional Commits](https://www.conventionalcommits.org/)
- Open a PR targeting `main` — squash merge only
- All PRs require 1 approval + passing CI checks
