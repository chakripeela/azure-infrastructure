resource "azurerm_kubernetes_cluster" "aks" {
  name                = "aks-todoapp-${var.location}"
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = "aks-todoapp-dns-${var.location}"

  default_node_pool {
    name       = "default"
    temporary_name_for_rotation = "rotatepool"
    node_count = 1
    vm_size    = "Standard_DC2s_v3"
    os_disk_size_gb = 30
    vnet_subnet_id = var.subnet_id
  }

  identity {
    type = "SystemAssigned"
  }

  key_vault_secrets_provider {
    secret_rotation_enabled  = true
    secret_rotation_interval = "2m"
  }

  network_profile {
    network_plugin = "azure"
  }

  sku_tier = "Free"
}