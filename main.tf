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

resource "azurerm_key_vault_secret" "wfbill_store_accesskey" {
  name      = "${var.organisation}${var.department}${var.environment}${var.project}-accesskey"
  value     = "${azurerm_storage_account.wfbill_storage_account.primary_access_key}"
  vault_uri = "${data.azurerm_key_vault.wfcore_key_vault.vault_uri}"

  tags {
    environment  = "${var.environment}"
    department   = "${var.department}"
    organisation = "${var.organisation}"
  }
}

resource "azurerm_app_service_plan" "wfbill_app_service_plan" {
  name                = "${var.organisation}${var.department}${var.environment}${var.project}"
  location            = "${azurerm_resource_group.wfbill_resource_group.location}"
  resource_group_name = "${azurerm_resource_group.wfbill_resource_group.name}"

  sku {
    tier = "Standard"
    size = "S1"
  }
}

resource "azurerm_function_app" "wfbill_function_app" {
  name                      = "${var.organisation}${var.department}${var.environment}${var.project}"
  location                  = "${azurerm_resource_group.wfbill_resource_group.location}"
  resource_group_name       = "${azurerm_resource_group.wfbill_resource_group.name}"
  app_service_plan_id       = "${azurerm_app_service_plan.wfbill_app_service_plan.id}"
  storage_connection_string = "${azurerm_storage_account.wfbill_storage_account.primary_connection_string}"
}

data "azurerm_client_config" "current" {}

resource "azurerm_key_vault_access_policy" "wfbill_app_policy" {
  vault_name          = "${data.azurerm_key_vault.wfcore_key_vault.name}"
  resource_group_name = "${data.azurerm_key_vault.wfcore_key_vault.resource_group_name}"

  tenant_id = "${data.azurerm_client_config.current.tenant_id}"
  object_id = "${azurerm_function_app.wfbill_function_app.id}"

  key_permissions = [
    "get",
  ]

  secret_permissions = [
    "get",
  ]
}
