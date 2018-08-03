#Persist our state to blob storage
terraform {
  backend "azurerm" {
    storage_account_name = "wfecom2020state"
    container_name       = "wfecom2020state"
    key                  = "terraform.polbill.state"
  }
}

provider "azurerm" {
  version = "~> 1.11.0"
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

data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "wfcore_key_vault" {
  name                = "${var.organisation}${var.department}${var.environment}-core"
  location            = "${azurerm_resource_group.wfbill_resource_group.location}"
  resource_group_name = "${azurerm_resource_group.wfbill_resource_group.name}"
  tenant_id           = "${data.azurerm_client_config.current.tenant_id}"

  access_policy {
    tenant_id = "${data.azurerm_client_config.current.tenant_id}"
    object_id = "${data.azurerm_client_config.current.service_principal_object_id}"

    key_permissions = [
      "create",
      "get",
      "list",
      "backup",
      "decrypt",
      "delete",
      "encrypt",
      "get",
      "import",
      "list",
      "purge",
      "recover",
      "restore",
      "sign",
      "unwrapKey",
      "update",
      "verify",
      "wrapKey",
    ]

    secret_permissions = [
      "backup",
      "delete",
      "get",
      "list",
      "purge",
      "recover",
      "set",
      "restore",
    ]
  }

  sku {
    name = "standard"
  }
}

# #Create a local storage account for our application


# resource "azurerm_storage_account" "wfbill_storage_account" {
#   name                     = "${var.organisation}${var.department}${var.environment}${var.project}"
#   resource_group_name      = "${azurerm_resource_group.wfbill_resource_group.name}"
#   location                 = "${azurerm_resource_group.wfbill_resource_group.location}"
#   account_tier             = "Standard"
#   account_replication_type = "GRS"


#   tags {
#     environment  = "${var.environment}"
#     department   = "${var.department}"
#     organisation = "${var.organisation}"
#   }
# }


# #Get a reference to the keyvault as we want to push the storage connection string to it
# data "azurerm_key_vault" "wfcore_key_vault" {
#   name                = "wfinfraprd-core"
#   resource_group_name = "wf-infra-prd-core"
# }


# #Save the storage connection string to the key vault
# resource "azurerm_key_vault_secret" "wfbill_store_accesskey" {
#   name      = "${var.organisation}${var.department}${var.environment}${var.project}-accesskey"
#   value     = "${azurerm_storage_account.wfbill_storage_account.primary_connection_string}"
#   vault_uri = "${data.azurerm_key_vault.wfcore_key_vault.vault_uri}"


#   tags {
#     environment  = "${var.environment}"
#     department   = "${var.department}"
#     organisation = "${var.organisation}"
#   }
# }


# #Ceate an app service plan
# resource "azurerm_app_service_plan" "wfbill_app_service_plan" {
#   name                = "${var.organisation}${var.department}${var.environment}${var.project}"
#   location            = "${azurerm_resource_group.wfbill_resource_group.location}"
#   resource_group_name = "${azurerm_resource_group.wfbill_resource_group.name}"


#   sku {
#     tier = "Standard"
#     size = "S1"
#   }
# }


# #Create a function app which is registered with Azure AD
# resource "azurerm_function_app" "wfbill_function_app" {
#   name                      = "${var.organisation}${var.department}${var.environment}${var.project}"
#   location                  = "${azurerm_resource_group.wfbill_resource_group.location}"
#   resource_group_name       = "${azurerm_resource_group.wfbill_resource_group.name}"
#   app_service_plan_id       = "${azurerm_app_service_plan.wfbill_app_service_plan.id}"
#   storage_connection_string = "${azurerm_storage_account.wfbill_storage_account.primary_connection_string}"


#   identity {
#     type = "SystemAssigned"
#   }


#   app_settings {
#     "KeyVaultLocation" = "${data.azurerm_key_vault.wfcore_key_vault.vault_uri}"
#   }
# }


# #Get a handle to the current client, so that we can get the tenant_id
# data "azurerm_client_config" "wfbill_client_config" {}


# #Give the new function app access to key vault
# resource "azurerm_key_vault_access_policy" "wfbill_app_policy" {
#   vault_name          = "${data.azurerm_key_vault.wfcore_key_vault.name}"
#   resource_group_name = "${data.azurerm_key_vault.wfcore_key_vault.resource_group_name}"


#   tenant_id = "${data.azurerm_client_config.wfbill_client_config.tenant_id}"
#   object_id = "${azurerm_function_app.wfbill_function_app.identity.0.principal_id}"


#   key_permissions = []


#   secret_permissions = [
#     "backup",
#     "delete",
#     "get",
#     "list",
#     "purge",
#     "recover",
#     "set",
#     "restore",
#   ]


#   depends_on = ["azurerm_function_app.wfbill_function_app"]
# }

