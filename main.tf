terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.55.0"
    }

    time = {
      source  = "hashicorp/time"
      version = "0.12.1"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.25.2"
    }
  }
}

provider "azurerm" {
  features {}
}

provider "kubernetes" {
  host                   = module.aks.host
  client_certificate     = base64decode(module.aks.kube_config[0].client_certificate)
  client_key             = base64decode(module.aks.kube_config[0].client_key)
  cluster_ca_certificate = base64decode(module.aks.kube_config[0].cluster_ca_certificate)
}

module "resource_group" {
  source           = "./resource-group"
  application_name = var.application_name
  location         = var.location
}

# Dedicated App Identity
resource "azurerm_user_assigned_identity" "app_identity" {
  name                = "${var.application_name}-api-identity"
  location            = var.location
  resource_group_name = module.resource_group.resource_group_name
}

# DR App Identity
resource "azurerm_user_assigned_identity" "app_identity_dr" {
  count               = var.is_dr ? 1 : 0
  name                = "${var.application_name}-dr-api-identity"
  location            = var.dr_location
  resource_group_name = module.resource_group_dr[0].resource_group_name
}

module "log_analytics" {
  source                          = "./common/log-analytics"
  location                        = var.location
  resource_group_name             = module.resource_group.resource_group_name
  workspace_name                  = "${var.application_name}-${var.location}-law"
  app_insights_name               = "${var.application_name}-${var.location}-ai"
  log_analytics_retention_in_days = var.log_analytics_retention_in_days
  app_insights_retention_in_days  = var.application_insights_retention_in_days
}

module "virtual_network" {
  source                = "./virtual-network"
  application_name      = var.application_name
  location              = var.location
  resource_group_name   = module.resource_group.resource_group_name
  shared_resource_group = module.resource_group.shared_resource_group_name
}

module "app_service" {
  source              = "./compute/app-service"
  plan_name           = "${var.application_name}-plan"
  location            = var.location
  resource_group_name = module.resource_group.resource_group_name
  subnet_id           = module.virtual_network.subnet_appsvc_id
  api_internal_ip     = local.aks_api_internal_ip_final
  #shared_resource_group = module.resource_group.shared_resource_group_name
}

module "acr" {
  source                     = "./compute/acr"
  application_name           = var.application_name
  acr_name                   = "chakripeelaacr"
  location                   = var.location
  resource_group_name        = module.resource_group.resource_group_name
  log_analytics_workspace_id = module.log_analytics.workspace_id
}

module "aks" {
  source                     = "./compute/aks"
  location                   = var.location
  resource_group_name        = module.resource_group.resource_group_name
  subnet_id                  = module.virtual_network.subnet_aks_id
  log_analytics_workspace_id = module.log_analytics.workspace_id
}

# Query the dynamically assigned LoadBalancer IP for the todo-api service
data "kubernetes_service" "todo_api" {
  depends_on = [module.aks]

  metadata {
    name      = "todo-api"
    namespace = "default"
  }
}

locals {
  aks_api_internal_ip_discovered = try(data.kubernetes_service.todo_api.status[0].load_balancer[0].ingress[0].ip, null)
  aks_api_internal_ip_final      = local.aks_api_internal_ip_discovered != null ? local.aks_api_internal_ip_discovered : var.aks_api_internal_ip
}

module "sql" {
  source                     = "./data/sql"
  application_name           = var.application_name
  location                   = var.location
  sql_server_location        = coalesce(var.sql_location, var.location)
  resource_group_name        = module.resource_group.resource_group_name
  subnet_id                  = module.virtual_network.subnet_sql_id
  sql_private_dns_zone_id    = module.virtual_network.sql_private_dns_zone_id
  sql_server_name            = var.sql_server_name
  sql_aad_admin_login        = azurerm_user_assigned_identity.app_identity.name
  sql_aad_admin_object_id    = azurerm_user_assigned_identity.app_identity.principal_id
  sql_database_name          = var.sql_database_name
  enable_failover_group      = var.is_dr ? true : false
  dr_sql_server_id           = var.is_dr ? module.sql_dr[0].sql_server_id : null
  log_analytics_workspace_id = module.log_analytics.workspace_id
}

# Conditional deployment: Application Gateway or Azure Front Door
module "app_gateway" {
  source                     = "./compute/app-gateway"
  application_name           = var.application_name
  location                   = var.location
  resource_group_name        = module.resource_group.resource_group_name
  subnet_id                  = module.virtual_network.subnet_appgw_id
  app_service_fqdn           = module.app_service.app_service_default_hostname
  backend_ip                 = local.aks_api_internal_ip_final
  appgw_nsg_assoc_id         = module.virtual_network.appgw_nsg_assoc_id
  log_analytics_workspace_id = module.log_analytics.workspace_id
}

module "frontdoor" {
  source                     = "./compute/frontdoor"
  application_name           = var.application_name
  location                   = var.location
  resource_group_name        = module.resource_group.resource_group_name
  app_service_fqdn           = module.app_service.app_service_default_hostname
  dr_appgw_public_ip         = var.is_dr ? module.app_gateway_dr[0].appgw_public_ip : null
  dr_enabled                 = var.is_dr ? true : false
  log_analytics_workspace_id = module.log_analytics.workspace_id
  depends_on                 = [module.app_gateway, module.app_gateway_dr]
}

# DR Modules
# DR region resource group
module "resource_group_dr" {
  count            = var.is_dr ? 1 : 0
  source           = "./resource-group"
  application_name = "${var.application_name}-dr"
  location         = var.dr_location
}
# DR region App Gateway
module "app_gateway_dr" {
  count                      = var.is_dr ? 1 : 0
  source                     = "./compute/app-gateway"
  application_name           = "${var.application_name}-dr"
  location                   = var.dr_location
  resource_group_name        = module.resource_group_dr[0].resource_group_name
  subnet_id                  = module.virtual_network_dr[0].subnet_appgw_id
  app_service_fqdn           = module.app_service_dr[0].app_service_default_hostname
  backend_ip                 = local.aks_api_internal_ip_final
  appgw_nsg_assoc_id         = module.virtual_network_dr[0].appgw_nsg_assoc_id
  log_analytics_workspace_id = module.log_analytics.workspace_id
}

# DR region SQL
module "sql_dr" {
  count                      = var.is_dr ? 1 : 0
  source                     = "./data/sql"
  application_name           = "${var.application_name}-dr"
  location                   = var.dr_location
  sql_server_location        = coalesce(var.sql_dr_location, var.dr_location)
  resource_group_name        = module.resource_group_dr[0].resource_group_name
  subnet_id                  = module.virtual_network_dr[0].subnet_sql_id
  sql_private_dns_zone_id    = module.virtual_network_dr[0].sql_private_dns_zone_id
  sql_server_name            = "${var.sql_server_name}-dr"
  sql_database_name          = "${var.sql_database_name}-dr"
  sql_aad_admin_login        = azurerm_user_assigned_identity.app_identity_dr[0].name
  sql_aad_admin_object_id    = azurerm_user_assigned_identity.app_identity_dr[0].principal_id
  create_database            = false
  log_analytics_workspace_id = module.log_analytics_dr[0].workspace_id
}

# DR region AKS
module "aks_dr" {
  count                      = var.is_dr ? 1 : 0
  source                     = "./compute/aks"
  location                   = var.dr_location
  resource_group_name        = module.resource_group_dr[0].resource_group_name
  subnet_id                  = module.virtual_network_dr[0].subnet_aks_id
  log_analytics_workspace_id = module.log_analytics_dr[0].workspace_id
}

# DR region app service
module "app_service_dr" {
  count               = var.is_dr ? 1 : 0
  source              = "./compute/app-service"
  plan_name           = "${var.application_name}-dr-plan"
  location            = var.dr_location
  resource_group_name = module.resource_group_dr[0].resource_group_name
  subnet_id           = module.virtual_network_dr[0].subnet_appsvc_id
  api_internal_ip     = local.aks_api_internal_ip_final
  enabled             = var.dr_app_service_enabled
}

# DR region virtual network
module "virtual_network_dr" {
  count                 = var.is_dr ? 1 : 0
  source                = "./virtual-network"
  application_name      = "${var.application_name}-dr"
  location              = var.dr_location
  resource_group_name   = module.resource_group_dr[0].resource_group_name
  shared_resource_group = module.resource_group_dr[0].shared_resource_group_name
}

# Alerts
resource "azurerm_monitor_action_group" "alerts" {
  name                = "alert-action-group"
  resource_group_name = module.resource_group.resource_group_name
  short_name          = "alerts"

  email_receiver {
    name          = "admin"
    email_address = "admin@example.com" # Replace with actual email
  }
}

resource "azurerm_monitor_metric_alert" "app_gateway_5xx" {
  name                = "app-gateway-5xx-alert"
  resource_group_name = module.resource_group.resource_group_name
  scopes              = [module.app_gateway.appgw_id]
  description         = "Alert when Application Gateway has unhealthy backends"
  severity            = 2

  criteria {
    metric_namespace = "Microsoft.Network/applicationGateways"
    metric_name      = "UnhealthyHostCount"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 0
  }

  action {
    action_group_id = azurerm_monitor_action_group.alerts.id
  }
}

resource "azurerm_monitor_metric_alert" "aks_pod_restarts" {
  name                = "aks-pod-restarts-alert"
  resource_group_name = module.resource_group.resource_group_name
  scopes              = [module.aks.aks_id]
  description         = "Alert when AKS pods restart frequently"
  severity            = 2

  criteria {
    metric_namespace = "Microsoft.ContainerService/managedClusters"
    metric_name      = "node_cpu_usage_percentage"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 80 # Example threshold
  }

  action {
    action_group_id = azurerm_monitor_action_group.alerts.id
  }
}

# Add more alerts as needed for SQL, Key Vault, etc.

module "log_analytics_dr" {
  count                           = var.is_dr ? 1 : 0
  source                          = "./common/log-analytics"
  location                        = var.dr_location
  resource_group_name             = module.resource_group_dr[0].resource_group_name
  workspace_name                  = "${var.application_name}-${var.dr_location}-law"
  app_insights_name               = "${var.application_name}-${var.dr_location}-ai"
  log_analytics_retention_in_days = var.log_analytics_retention_in_days
  app_insights_retention_in_days  = var.application_insights_retention_in_days
}