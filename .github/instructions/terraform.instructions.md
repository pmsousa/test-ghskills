---
applyTo: "**/*.tf"
---

- When adding reusable infrastructure, create child modules under `infra/modules/<module-name>/` rather than inlining everything in `main.tf`
- All resources must include `tags = local.tags`
- Naming convention: `<type>-<project>-<environment>-<location_short>` (e.g. `rg-blog-production-westeu`); ACR names replace hyphens with empty string
- Check `infra/providers.tf` for the pinned `azurerm` version before generating resources — do not use attributes introduced in a later version
- Use `locals` for repeated expressions; prefer `var.` references over hardcoded values
- Place backend configuration in `infra/environments/<env>/backend.hcl` — never inline backend config
- The Container App image is managed by the CD workflow; always include `lifecycle { ignore_changes = [template[0].container[0].image] }` on `azurerm_container_app` resources
