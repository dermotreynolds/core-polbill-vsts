#Allow our state to be persisted in blob storage
terraform {
  backend "azurerm" {
    storage_account_name = "wfinfraprd010101"
    container_name       = "wfinfraprdstate010101"
    key                  = "terraform.polbill.state"
  }
}

#Create a resource group to put our resources into
resource "azurerm_resource_group" "wfbill_resource_group" {
  name     = "${var.organisation}-${var.department}-${var.environment}-${var.project}"
  location = "${var.azure_location}"

  tags {
    environment  = "${var.environment}"
    department   = "${var.department}"
    organisation = "${var.organisation}"
  }
}

resource "azurerm_storage_account" "wfbill_storage_account" {
  name                     = "${var.organisation}${var.department}${var.environment}${var.project}"
  resource_group_name      = "${azurerm_resource_group.wfbill_resource_group.name}"
  location                 = "${azurerm_resource_group.wfbill_resource_group.location}"
  account_tier             = "Standard"
  account_replication_type = "GRS"

  tags {
    environment  = "${var.environment}"
    department   = "${var.department}"
    organisation = "${var.organisation}"
  }
}

data "azurerm_key_vault" "wfcore_key_vault" {
  name                = "wfinfraprd-core"
  resource_group_name = "wf-infra-prd-core"
}

resource "azurerm_key_vault_secret" "wfcore_key_vault" {
  name      = "${var.organisation}${var.department}${var.environment}${var.project}"
  value     = "${azurerm_storage_account.wfbill_storage_account.primary_access_key}"
  vault_uri = "${data.azurerm_key_vault.wfcore_key_vault.vault_uri}"

  tags {
    environment  = "${var.environment}"
    department   = "${var.department}"
    organisation = "${var.organisation}"
  }
}
