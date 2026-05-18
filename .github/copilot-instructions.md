# Copilot Instructions

## Project

Personal blog — a Vue.js SPA hosted on Azure Container Apps, built and pushed to Azure Container Registry via GitHub Actions, with infrastructure managed by Terraform.

## Stack

- **Frontend**: Vue.js 3 (Vite) in `src/`
- **Container**: Docker multi-stage (`node:22-alpine` → `nginx:1.27-alpine`)
- **IaC**: Terraform `~> 4.0` (azurerm) under `infra/`; single root module; environments under `infra/environments/`
- **Hosting**: Azure Container Apps (Consumption), ACR (Basic), Log Analytics
- **CI/CD**: GitHub Actions with OIDC (no client secrets); `az acr build` for image push; `az containerapp update` for deployment

## Conventions

- Follow Conventional Commits for all commit messages and PR titles
- All Terraform resources must include `tags = local.tags`
- Terraform naming: `<type>-<project>-<environment>-<location_short>` (e.g. `ca-blog-production-westeu`)
- The CD workflow owns the Container App image tag; Terraform ignores it via `lifecycle { ignore_changes = [template[0].container[0].image] }`
- Never commit `.tfstate`, backend credentials, or `.env` files
- Use `az acr build` (cloud build) — never require a local Docker daemon in CI
- OIDC auth only in GitHub Actions — never use `AZURE_CLIENT_SECRET`
