output "aks_id" {
  description = "ID of the AKS cluster"
  value       = azurerm_kubernetes_cluster.aks.id
}

output "kubelet_object_id" {
  value = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
}

output "kubelet_client_id" {
  description = "Client ID of the AKS kubelet managed identity (used for SQL access)"
  value       = azurerm_kubernetes_cluster.aks.kubelet_identity[0].client_id
}

output "cluster_identity_principal_id" {
  description = "Principal ID of the AKS cluster system-assigned managed identity"
  value       = azurerm_kubernetes_cluster.aks.identity[0].principal_id
}

output "key_vault_secrets_provider_object_id" {
  description = "Object ID of the Key Vault Secrets Provider (CSI driver) managed identity"
  value       = azurerm_kubernetes_cluster.aks.key_vault_secrets_provider[0].secret_identity[0].object_id
}

output "key_vault_secrets_provider_client_id" {
  description = "Client ID of the Key Vault Secrets Provider (CSI driver) managed identity"
  value       = azurerm_kubernetes_cluster.aks.key_vault_secrets_provider[0].secret_identity[0].client_id
}

output "kube_config" {
  description = "Kubernetes cluster config for provider configuration"
  value       = azurerm_kubernetes_cluster.aks.kube_config_raw
  sensitive   = true
}

output "host" {
  description = "Kubernetes cluster API server URL"
  value       = azurerm_kubernetes_cluster.aks.kube_config[0].host
  sensitive   = true
}
