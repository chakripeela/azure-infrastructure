# Future Enhancements

## Quick Wins

### Add Observability And Alerting

The platform has enough moving parts that troubleshooting will become expensive without centralized telemetry.

Recommended direction:

- Add Log Analytics
- Add Application Insights for UI and API
- Enable diagnostic settings for AKS, Front Door, Application Gateway, Key Vault, SQL, and ACR
- Add alerts for:
  - 5xx spikes
  - unhealthy backends and probes
  - pod restarts and crash loops
  - SQL failover and connectivity errors
  - secret access failures

### Add WAF Protection

Application Gateway is now restricted to Front Door backend traffic, but there is no web application firewall policy in front of the application path.

Recommended direction:

- Add Azure Front Door WAF as the first layer of protection
- Optionally evaluate Application Gateway WAF if regional inspection is also needed

### Strengthen DR Readiness

The platform has the foundations of DR, but it would benefit from more explicit operational readiness.

Recommended direction:

- Document a DR runbook
- Validate that DR Key Vault, DR AKS, DR App Service, and SQL failover all work without manual fixes
- Perform regular failover testing
- Review whether SQL failover mode should remain manual or become automatic

## Medium Effort

### Add Autoscaling

The current stack uses a fixed AKS node count and minimal application scaling.

Why:

- Limits resilience
- Can overpay at low load and underperform at high load

Recommended direction:

- Enable AKS cluster autoscaler
- Add a Horizontal Pod Autoscaler for the API
- Review App Service scaling strategy for the UI

### Separate Schema Management From Runtime

Database schema changes should not depend on normal application runtime permissions.

Why:

- Runtime should not need DDL rights
- Easier auditing and safer deployments

Recommended direction:

- Use a dedicated schema migration workflow or migration tool
- Keep normal runtime permissions limited to data read/write only

### Revisit ACR Exposure

ACR is currently publicly accessible for simplicity.

Why:

- Fine for stabilization, but not ideal long term

Recommended direction:

- Restrict ACR to selected networks or trusted build agents
- Reintroduce private access later only after DNS and routing design are stable

## Larger Architectural Changes

### Dedicated App Identity

Replace the current use of the AKS kubelet identity for database access with a dedicated user-assigned managed identity for the API workload.

Why:

- Separates application permissions from cluster/node permissions
- Simplifies failover and permission management
- Reduces blast radius if cluster identity changes

Recommended direction:

- Use Azure Workload Identity or a dedicated managed identity bound to the API workload
- Store only app-specific identity references in Key Vault if still needed

### Remove Hardcoded Internal API IP

The internal API endpoint currently depends on the fixed private IP `10.1.2.250`.

Why:

- Brittle coupling between App Service, App Gateway, and the Kubernetes `LoadBalancer` service
- Harder to evolve networking safely

Recommended direction:

- Move the IP to an explicit Terraform variable at minimum
- Prefer a cleaner ingress-based pattern so App Gateway targets a Kubernetes ingress instead of a pinned service IP

## Recommended Order

If enhancements are taken up incrementally, the highest-value order is:

1. Introduce a dedicated application identity instead of using the kubelet identity
2. Remove the hardcoded internal API IP dependency
3. Add observability and alerting before the system grows further
