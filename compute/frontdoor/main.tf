
data "azurerm_application_gateway" "appgateway" {
  name                = "appgw-${var.application_name}"
  resource_group_name = "${var.resource_group_name}"
}

data "azurerm_public_ip" "appgwpublicip" {
  name                = "pip-appgw-${var.application_name}"
  resource_group_name = "${var.resource_group_name}"
}

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
  host_name                       = data.azurerm_public_ip.appgwpublicip.ip_address
  http_port                       = 80
  https_port                      = 443
  origin_host_header              = data.azurerm_public_ip.appgwpublicip.ip_address
  enabled                         = true
  certificate_name_check_enabled   = false
  priority                        = 1
  weight                          = 1000
}

resource "azurerm_cdn_frontdoor_origin" "dr_appservice" {
  count                           = var.dr_enabled ? 1 : 0
  name                            = "dr-appservice-origin"
  cdn_frontdoor_origin_group_id   = azurerm_cdn_frontdoor_origin_group.main.id
  host_name                       = var.dr_appgw_public_ip
  http_port                       = 80
  https_port                      = 443
  origin_host_header              = var.dr_appgw_public_ip
  enabled                         = true
  certificate_name_check_enabled  = false
  priority                        = 2
  weight                          = 1000
}

resource "azurerm_cdn_frontdoor_route" "main" {
  name                           = "fd-route-${var.application_name}-${var.location}"
  cdn_frontdoor_endpoint_id      = azurerm_cdn_frontdoor_endpoint.main.id
  cdn_frontdoor_origin_group_id  = azurerm_cdn_frontdoor_origin_group.main.id
  cdn_frontdoor_origin_ids       = var.dr_enabled ? [
    azurerm_cdn_frontdoor_origin.appservice.id,
    azurerm_cdn_frontdoor_origin.dr_appservice[0].id
  ] : [
    azurerm_cdn_frontdoor_origin.appservice.id
  ]
  patterns_to_match              = ["/*"]
  supported_protocols            = ["Http", "Https"]
  forwarding_protocol            = "HttpOnly"
  https_redirect_enabled         = false
}
