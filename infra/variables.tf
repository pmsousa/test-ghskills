variable "environment" {
  description = "Deployment environment name (e.g. production, staging)."
  type        = string
}

variable "location" {
  description = "Azure region for all resources."
  type        = string
  default     = "westeurope"
}

variable "location_short" {
  description = "Short location identifier used in resource names (e.g. westeu)."
  type        = string
  default     = "westeu"
}

variable "project" {
  description = "Project short name used in resource naming."
  type        = string
  default     = "blog"
}

variable "container_image_tag" {
  description = "Docker image tag deployed to the Container App. Managed by the CD workflow."
  type        = string
  default     = "latest"
}
