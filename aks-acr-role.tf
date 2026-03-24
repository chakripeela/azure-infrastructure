resource "azurerm_role_assignment" "aks_acr_pull" {
  scope                = module.acr.acr_id
  role_definition_name = "AcrPull"
  principal_id         = module.aks.kubelet_object_id
}

resource "azurerm_role_assignment" "aks_network_contributor" {
  scope                = module.virtual_network.subnet_aks_id
  role_definition_name = "Network Contributor"
  principal_id         = module.aks.cluster_identity_principal_id
}
