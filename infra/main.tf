locals {
  name_suffix = "${var.project}-${var.environment}-${var.location_short}"

  tags = {
    project     = var.project
    environment = var.environment
    managed_by  = "terraform"
  }
}

# --- Resource Group ---

resource "azurerm_resource_group" "main" {
  name     = "rg-${local.name_suffix}"
  location = var.location
  tags     = local.tags
}

# --- Container Registry ---

resource "azurerm_container_registry" "main" {
  name                = "cr${replace(local.name_suffix, "-", "")}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  sku                 = "Basic"
  admin_enabled       = false
  tags                = local.tags
}

# --- Observability ---

resource "azurerm_log_analytics_workspace" "main" {
  name                = "law-${local.name_suffix}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags                = local.tags
}

# --- Container Apps Environment ---

resource "azurerm_container_app_environment" "main" {
  name                       = "cae-${local.name_suffix}"
  resource_group_name        = azurerm_resource_group.main.name
  location                   = azurerm_resource_group.main.location
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id
  tags                       = local.tags
}

# --- Container App ---

resource "azurerm_container_app" "blog" {
  name                         = "ca-${local.name_suffix}"
  resource_group_name          = azurerm_resource_group.main.name
  container_app_environment_id = azurerm_container_app_environment.main.id
  revision_mode                = "Single"
  tags                         = local.tags

  identity {
    type = "SystemAssigned"
  }

  registry {
    server   = azurerm_container_registry.main.login_server
    identity = "System"
  }

  ingress {
    external_enabled = true
    target_port      = 80
    transport        = "auto"

    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }

  template {
    min_replicas = 0
    max_replicas = 3

    container {
      name   = "blog"
      image  = "${azurerm_container_registry.main.login_server}/${var.project}:${var.container_image_tag}"
      cpu    = 0.25
      memory = "0.5Gi"
    }
  }

  # The CD workflow updates the image tag directly via az containerapp update.
  # Prevent Terraform from reverting the image on subsequent infra applies.
  lifecycle {
    ignore_changes = [template[0].container[0].image]
  }
}

# --- RBAC: allow Container App managed identity to pull from ACR ---
# Applied after Container App creation (principal_id creates implicit dependency).
# AcrPull propagation is near-instant; the first revision pull succeeds within seconds.

resource "azurerm_role_assignment" "acr_pull" {
  scope                = azurerm_container_registry.main.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_container_app.blog.identity[0].principal_id
}
