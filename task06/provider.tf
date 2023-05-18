terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }
}

provider "azurerm" {
  features {}

  client_id                   = "4f8e2f20-17bf-4b00-945d-b034b447e228"
  client_certificate_path     = var.client_certificate_path
  client_certificate_password = var.client_certificate_password
  tenant_id                   = "3895a181-a088-406c-a287-08e66dff678b"
  subscription_id             = "7ff2cce6-aa95-45c0-b03b-9453468761fa"
}
