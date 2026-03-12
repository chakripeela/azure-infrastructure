resource "azurerm_kubernetes_cluster" "aks" {
  name                = "aks-learning"
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = "akslearn"

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "standard_b2pls_v2"
    os_disk_size_gb = 30
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin = "kubenet"
  }

  sku_tier = "Free"
}