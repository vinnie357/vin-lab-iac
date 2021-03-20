terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }
    template = {
      source = "hashicorp/template"
    }
  }
  required_version = ">= 0.13"
}
