---
applyTo: ".github/workflows/**"
---

- All jobs must include `timeout-minutes`
- Azure authentication must use OIDC via `azure/login@v2` — never use `AZURE_CLIENT_SECRET`
- Required secrets: `AZURE_CLIENT_ID`, `AZURE_TENANT_ID`, `AZURE_SUBSCRIPTION_ID`
- Required vars: `ACR_NAME`, `ACR_LOGIN_SERVER`, `CONTAINER_APP_NAME`, `RESOURCE_GROUP`
- Deployment jobs must specify `environment: production` to gate through GitHub environment protection rules
- Use `az acr build` for Docker builds — no local Docker daemon required in CI
- Set `permissions` explicitly at job level with least privilege
- Use `actions/checkout@v4` and other latest major-pinned actions
