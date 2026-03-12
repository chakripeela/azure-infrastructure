resource "azurerm_kubernetes_cluster" "aks" {
  name                = "aks-learning"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "akslearn"

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_B1s"
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