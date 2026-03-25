# Azure Front Door Terraform resource (minimal example)
resource "azurerm_frontdoor" "main" {
  count               = var.gateway_type == "frontdoor" ? 1 : 0
  name                = "fd-${var.application_name}-${var.location}"
  resource_group_name = var.resource_group_name
  # VNet integration (subnet_id) for Front Door Premium (if supported)
  # Uncomment the following line if using Premium SKU and VNet integration is required:
  # subnet_id = var.subnet_id

  frontend_endpoint {
    name                              = "default-frontend-endpoint"
    host_name                         = "fd-${var.application_name}-${var.location}.azurefd.net"
  }

  # App Service (UI)
  backend_pool {
    name = "backend-pool-appservice"
    backend {
      host_header = var.app_service_fqdn
      address     = var.app_service_fqdn
      http_port   = 80
      https_port  = 443
      weight      = 50
      priority    = 1
    }
    load_balancing_name = "default-lb"
    health_probe_name   = "default-probe"
  }

  # AKS API (internal LB)
  backend_pool {
    name = "backend-pool-aks-api"
    backend {
      host_header = var.backend_ip
      address     = var.backend_ip
      http_port   = 80
      https_port  = 443
      weight      = 50
      priority    = 1
    }
    load_balancing_name = "default-lb"
    health_probe_name   = "default-probe"
  }

  backend_pool_health_probe {
    name                = "default-probe"
    protocol            = "Http"
    path                = "/"
    interval_in_seconds = 30
  }

  backend_pool_load_balancing {
    name                            = "default-lb"
    sample_size                     = 4
    successful_samples_required     = 2
    additional_latency_milliseconds = 0
  }

  routing_rule {
    name               = "default-routing-rule"
    accepted_protocols = ["Http", "Https"]
    patterns_to_match  = ["/*"]
    frontend_endpoints = ["default-frontend-endpoint"]
    forwarding_configuration {
      forwarding_protocol = "MatchRequest"
      backend_pool_name   = "default-backend-pool"
    }
  }
}
