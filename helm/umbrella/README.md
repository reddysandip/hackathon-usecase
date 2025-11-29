# Healthcare Umbrella Helm Chart

This umbrella chart deploys three services:
- patient-service (Node.js)
- application-service (Node.js)
- order-service (Java)

## Usage

Package and install:

```bash
helm dependency update helm/umbrella
helm install healthcare helm/umbrella -n default
```

Override image repositories/tags (e.g., ACR, Java 21 tag for order-service):

```bash
helm install healthcare helm/umbrella \
  --set global.registry=myacr.azurecr.io \
  --set patient-service.image.repository=patient-service \
  --set application-service.image.repository=application-service \
  --set order-service.image.repository=order-service \
  --set patient-service.image.tag=1.0.0 \
  --set application-service.image.tag=1.0.0 \
  --set order-service.image.tag=jdk21
```

To uninstall:

```bash
helm uninstall healthcare -n default
```

## Key Vault CSI (optional)
Enable mounting secrets via Azure Key Vault CSI driver:

```bash
helm upgrade --install healthcare helm/umbrella -n default \
  --set global.registry=myteamregistry.azurecr.io \
  --set global.keyvault.enabled=true \
  --set global.keyvault.name=<kv-name> \
  --set global.keyvault.tenantId=<tenant-id> \
  --set-json 'global.keyvault.objects=[{"objectName":"app-secret","objectType":"secret"}]'
```

Secrets will be available at `/mnt/secrets` in each pod.
