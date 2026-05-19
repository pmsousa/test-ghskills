output "resource_group_name" {
  description = "Name of the resource group containing all blog resources."
  value       = azurerm_resource_group.main.name
}

output "acr_login_server" {
  description = "Login server URL for the Azure Container Registry."
  value       = azurerm_container_registry.main.login_server
}

output "acr_name" {
  description = "Name of the Azure Container Registry (used with az acr build)."
  value       = azurerm_container_registry.main.name
}

output "container_app_name" {
  description = "Name of the Container App."
  value       = azurerm_container_app.blog.name
}

output "container_app_url" {
  description = "Public HTTPS URL of the blog."
  value       = "https://${azurerm_container_app.blog.ingress[0].fqdn}"
}
