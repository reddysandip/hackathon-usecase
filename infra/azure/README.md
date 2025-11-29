# Azure IaC (Terraform)

Provision Azure resources for AKS deployment with Azure CNI and Managed Identity.

Resources per environment (dev/staging/prod):
- Resource Group
- Virtual Network + AKS Subnet (Azure CNI)
- Log Analytics Workspace (Container Insights)
- ACR (AcrPull role to AKS kubelet identity)
- Key Vault (RBAC enabled)
- AKS (System-assigned managed identity, Azure CNI)

## Remote State
Use Azure Storage for remote state. Create the storage account & container once (can be via module). Fill `backend.tfvars` values.

## Usage

```bash
# Log in
az login
az account set --subscription <SUBSCRIPTION_ID>

# Initialize backend (example dev)
cd infra/azure/envs/dev
terraform init \
  -backend-config="resource_group_name=hc-dev-rg" \
  -backend-config="storage_account_name=hcdevtfstate" \
  -backend-config="container_name=tfstate" \
  -backend-config="key=dev/terraform.tfstate"

# Plan & Apply
terraform plan -var "subscription_id=<SUB_ID>" -var "tenant_id=<TENANT_ID>"
terraform apply -auto-approve -var "subscription_id=<SUB_ID>" -var "tenant_id=<TENANT_ID>"
```

After AKS is ready, get credentials:

```bash
az aks get-credentials -g hc-dev-rg -n hc-dev-aks
```

Then deploy Helm chart:

```bash
helm dependency update helm/umbrella
helm install healthcare helm/umbrella -n default \
  --set global.registry=$(az acr show -n hcdevacr --query loginServer -o tsv)
```
