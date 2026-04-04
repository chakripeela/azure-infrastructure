resource "azurerm_role_assignment" "aks_acr_pull" {
  scope                = module.acr.acr_id
  role_definition_name = "AcrPull"
  principal_id         = module.aks.kubelet_object_id
}

resource "azurerm_role_assignment" "aks_dr_acr_pull" {
  count = var.is_dr ? 1 : 0

  scope                = module.acr.acr_id
  role_definition_name = "AcrPull"
  principal_id         = module.aks_dr[0].kubelet_object_id
}

resource "azurerm_role_assignment" "aks_network_contributor" {
  scope                = module.virtual_network.subnet_aks_id
  role_definition_name = "Network Contributor"
  principal_id         = module.aks.cluster_identity_principal_id
}

resource "azurerm_role_assignment" "aks_dr_network_contributor" {
  count = var.is_dr ? 1 : 0

  scope                = module.virtual_network_dr[0].subnet_aks_id
  role_definition_name = "Network Contributor"
  principal_id         = module.aks_dr[0].cluster_identity_principal_id
}
