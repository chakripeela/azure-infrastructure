resource "azurerm_public_ip" "appgw_pip" {
  name                = "pip-appgw-${var.application_name}"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_application_gateway" "appgw" {
  name                = "appgw-${var.application_name}"
  location            = var.location
  resource_group_name = var.resource_group_name

  depends_on = [
    var.appgw_nsg_assoc_id
  ]

  sku {
    name     = "WAF_v2"
    tier     = "WAF_v2"
    capacity = 1
  }

  waf_configuration {
    enabled          = true
    firewall_mode    = "Prevention"
    rule_set_type    = "OWASP"
    rule_set_version = "3.2"

    disabled_rule_group {
      rule_group_name = "REQUEST-921-PROTOCOL-ATTACK"
      rules           = ["921150"]
    }
  }

  gateway_ip_configuration {
    name      = "appgw-ip-config"
    subnet_id = var.subnet_id
  }

  # ─── Frontend ───────────────────────────────────────────────
  frontend_ip_configuration {
    name                 = "appgw-frontend-ip"
    public_ip_address_id = azurerm_public_ip.appgw_pip.id
  }

  frontend_port {
    name = "http-port"
    port = 80
  }

  # ─── Backend Pools ──────────────────────────────────────────
  # App Service (UI)
  backend_address_pool {
    name  = "backend-pool-appservice"
    fqdns = [var.app_service_fqdn]
  }

  # AKS API (internal LB)
  backend_address_pool {
    name         = "backend-pool-aks-api"
    ip_addresses = [var.backend_ip]
  }

  # ─── Backend HTTP Settings ─────────────────────────────────
  backend_http_settings {
    name                                = "http-settings-appservice"
    cookie_based_affinity               = "Disabled"
    port                                = 443
    protocol                            = "Https"
    request_timeout                     = 30
    pick_host_name_from_backend_address = true

    probe_name = "probe-appservice"
  }

  backend_http_settings {
    name                  = "http-settings-aks-api"
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 30
    host_name             = var.backend_ip

    probe_name = "probe-aks-api"
  }

  # ─── Health Probes ─────────────────────────────────────────
  probe {
    name                                      = "probe-appservice"
    protocol                                  = "Https"
    path                                      = "/"
    interval                                  = 30
    timeout                                   = 30
    unhealthy_threshold                       = 3
    pick_host_name_from_backend_http_settings = true
  }

  probe {
    name                = "probe-aks-api"
    protocol            = "Http"
    host                = var.backend_ip
    path                = "/health"
    interval            = 30
    timeout             = 30
    unhealthy_threshold = 3
  }

  # ─── Listeners ─────────────────────────────────────────────
  http_listener {
    name                           = "listener-http"
    frontend_ip_configuration_name = "appgw-frontend-ip"
    frontend_port_name             = "http-port"
    protocol                       = "Http"
  }

  # ─── URL Path Map (path-based routing) ─────────────────────
  url_path_map {
    name                               = "url-path-map"
    default_backend_address_pool_name  = "backend-pool-appservice"
    default_backend_http_settings_name = "http-settings-appservice"

    path_rule {
      name                       = "api-rule"
      paths                      = ["/api/*"]
      backend_address_pool_name  = "backend-pool-aks-api"
      backend_http_settings_name = "http-settings-aks-api"
    }
  }

  # ─── Routing Rule ──────────────────────────────────────────
  request_routing_rule {
    name               = "routing-rule"
    priority           = 100
    rule_type          = "PathBasedRouting"
    http_listener_name = "listener-http"
    url_path_map_name  = "url-path-map"
  }
}

resource "azurerm_monitor_diagnostic_setting" "app_gateway" {
  name                       = "app-gateway-diagnostic"
  target_resource_id         = azurerm_application_gateway.appgw.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category = "ApplicationGatewayAccessLog"
  }

  enabled_log {
    category = "ApplicationGatewayPerformanceLog"
  }

  enabled_log {
    category = "ApplicationGatewayFirewallLog"
  }

  enabled_log {
    category = "AllMetrics"
  }
}
