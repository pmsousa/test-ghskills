terraform {
  required_version = ">= 1.9"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }

  # Values injected at init via -backend-config=environments/<env>/backend.hcl
  backend "azurerm" {}
}

provider "azurerm" {
  features {}
}
