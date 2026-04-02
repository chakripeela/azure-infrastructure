locals {
	#sanitized_application_name = regexreplace(lower(var.F), "[^a-z0-9]", "")

	function_app_name = coalesce(
		var.function_app_name,
		substr("func-${var.application_name}-${var.location}", 0, 60)
	)

	storage_account_name = coalesce(
		var.storage_account_name,
		substr("${var.application_name}${replace(lower(var.location), " ", "")}funcsa", 0, 24)
	)
}

resource "azurerm_storage_account" "function_storage" {
	name                     = local.storage_account_name
	resource_group_name      = var.resource_group_name
	location                 = var.location
	account_tier             = "Standard"
	account_replication_type = "LRS"
	account_kind             = "StorageV2"
	min_tls_version          = "TLS1_2"
}

resource "azurerm_linux_function_app" "function_app" {
	name                       = local.function_app_name
	location                   = var.location
	resource_group_name        = var.resource_group_name
	service_plan_id            = var.service_plan_id
	storage_account_name       = azurerm_storage_account.function_storage.name
	storage_account_access_key = azurerm_storage_account.function_storage.primary_access_key
	functions_extension_version = var.functions_extension_version
	https_only                 = true

	identity {
		type = "SystemAssigned"
	}

	site_config {
		application_stack {
			node_version = var.node_version
		}
	}

	app_settings = merge({
		"FUNCTIONS_WORKER_RUNTIME"              = "node"
		"WEBSITE_RUN_FROM_PACKAGE"              = "1"
		"AzureWebJobsStorage"                   = azurerm_storage_account.function_storage.primary_connection_string
		"WEBSITES_ENABLE_APP_SERVICE_STORAGE"   = "false"
	}, var.app_settings)
}
