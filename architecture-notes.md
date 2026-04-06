# Architecture Notes

## Resource Classification

### Regional Resources

These resources are deployed into a specific Azure region and need a separate instance in DR if you want regional redundancy.

- Resource groups
- Virtual networks and subnets
- AKS clusters
- App Service plans
- Linux Web Apps
- Application Gateways
- Application Gateway public IPs
- Key Vaults
- Azure SQL servers
- SQL private endpoints
- Azure Container Registry

### Global Resources

These resources provide a global entry point or globally distributed routing behavior rather than living as a single regional app instance.

- Azure Front Door profile
- Azure Front Door endpoint
- Azure Front Door origin group
- Azure Front Door origins
- Azure Front Door route

### Cross-Region Or Replicated Resources

These resources coordinate traffic or data across regions rather than representing a standalone workload in one region.

- Azure SQL failover group
- SQL failover group listener FQDN
- Front Door origin configuration spanning primary and DR Application Gateways

### Supporting Infrastructure

These resources support connectivity, security, or name resolution.

- Private DNS zones
- Private DNS virtual network links
- VNet peerings
- Network Security Groups
- NSG rules
- Role assignments

## Key Vault Design Note

Key Vault is a regional resource. In this design, keeping both a primary and DR Key Vault is still justified because the following values are cluster-specific:

- `managed-identity-client-id`
- AKS Secrets Provider access policy object ID

The `db-server` secret can be shared logically by using the SQL failover group listener FQDN, but the identity-related secrets remain region-specific because the primary and DR AKS clusters use different managed identities.

## Database Endpoint Design Note

When DR is enabled, both regions should use the SQL failover group read-write listener FQDN instead of a regional SQL server FQDN for application writes. This keeps write traffic pointed to whichever SQL server is currently primary.
