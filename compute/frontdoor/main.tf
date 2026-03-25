
# Azure Front Door Standard/Premium (CDN) resources
resource "azurerm_cdn_frontdoor_profile" "main" {
  name                = "fd-${var.application_name}-${var.location}"
  resource_group_name = var.resource_group_name
  sku_name            = "Standard_AzureFrontDoor"
}

resource "azurerm_cdn_frontdoor_endpoint" "main" {
  name                     = "fd-endpoint-${var.application_name}-${var.location}"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.main.id
}

resource "azurerm_cdn_frontdoor_origin_group" "main" {
  name                     = "fd-origingroup-${var.application_name}-${var.location}"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.main.id

  load_balancing {
    sample_size                        = 4
    successful_samples_required        = 3
    additional_latency_in_milliseconds = 50
  }

  health_probe {
    interval_in_seconds = 30
    path                = "/"
    protocol            = "Http"
  }
}

resource "azurerm_cdn_frontdoor_origin" "appservice" {
  name                            = "appservice-origin"
  cdn_frontdoor_origin_group_id   = azurerm_cdn_frontdoor_origin_group.main.id
  host_name                       = var.app_service_fqdn
  http_port                       = 80
  https_port                      = 443
  enabled                         = true
  certificate_name_check_enabled   = false
  priority                        = 1
  weight                          = 1000
}

resource "azurerm_cdn_frontdoor_origin" "aksapi" {
  name                            = "aksapi-origin"
  cdn_frontdoor_origin_group_id   = azurerm_cdn_frontdoor_origin_group.main.id
  host_name                       = var.backend_ip
  http_port                       = 80
  https_port                      = 443
  enabled                         = true
  certificate_name_check_enabled   = false
  priority                        = 2
  weight                          = 1000
}

resource "azurerm_cdn_frontdoor_route" "main" {
  name                           = "fd-route-${var.application_name}-${var.location}"
  cdn_frontdoor_endpoint_id      = azurerm_cdn_frontdoor_endpoint.main.id
  cdn_frontdoor_origin_group_id  = azurerm_cdn_frontdoor_origin_group.main.id
  cdn_frontdoor_origin_ids       = [
    azurerm_cdn_frontdoor_origin.appservice.id,
    azurerm_cdn_frontdoor_origin.aksapi.id
  ]
  patterns_to_match              = ["/*"]
  supported_protocols            = ["Http", "Https"]
  forwarding_protocol            = "MatchRequest"
  https_redirect_enabled         = true
}
