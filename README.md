# Azure Attack Simulation - Terraform Configuration

This Terraform module automates the setup of Azure resources for attack simulation and penetration testing.

## Prerequisites

### Required Tools

1. **Terraform** >= 1.0
   ```bash
   terraform --version
   ```

2. **Azure CLI** installed and authenticated
   ```bash
   az --version
   az login
   ```

3. **curl** (for getting your IP address)
   ```bash
   curl --version
   ```

### Azure Permissions

Your Azure account needs:
- **Contributor** role on subscription or resource group
- **User Access Administrator** role (for RBAC assignments)

Verify your permissions:
```bash
az role assignment list --assignee $(az account show --query user.name -o tsv) --output table
```

### Get Your Subscription ID

```bash
az account show --query id --output tsv
```

---

## Deployment Options

This module supports two deployment modes:

| Mode | `create_vm` | Use Case |
|------|-------------|----------|
| **Full deployment** | `true` (default) | Module creates VM, network, resource group, and all target resources |
| **Bring-your-own-VM** | `false` | Client provides their own VM and infrastructure; module creates only target resources (Key Vault, Storage, Function App, Service Principal) |

---

## Option A: Full Deployment (Module Creates Everything)

Use this when you want the module to create the VM, network stack, and all attack target resources.

### Minimal Configuration

```hcl
module "azure_attack_sim" {
  source  = "cyngularsecurity/attack-simulation/azure"

  subscription_id = "your-subscription-id"
  client_name     = "clienta"  # 3-8 chars, lowercase alphanumeric
  admin_password  = "password"
}

output "deployment_summary" {
  value = module.azure_attack_sim.deployment_summary
}

output "keyvault_name" {
  value = module.azure_attack_sim.keyvault_name
}

output "function_app_name" {
  value = module.azure_attack_sim.function_app_name
}

 output "ssh_connection_command" {
  value = module.azure_attack_sim.ssh_connection_command
}

output "vm_public_ip" {
  value = module.azure_attack_sim.vm_public_ip
}
```

### Full Configuration (All Options)

```hcl
module "azure_attack_sim" {
  source  = "cyngularsecurity/attack-simulation/azure"

  # Required
  subscription_id = var.subscription_id
  client_name     = var.client_name

  # Optional (with defaults)
  location               = "eastus"              # Azure region
  vm_size                = "Standard_B2s"        # VM size
  function_app_sku       = "B1"                  # B1/S1 for writable filesystem, Y1 for consumption
  admin_username         = "azureuser"           # VM username
  admin_password         = var.admin_password     # VM password (12+ chars, mixed case, number, special)
  vnet_address_space     = ["10.0.0.0/16"]       # VNet CIDR
  subnet_address_prefix  = ["10.0.1.0/24"]       # Subnet CIDR
  allowed_ssh_source_ips = ["YOUR_IP/32"]        # Restrict SSH access!
}

output "deployment_summary" {
  value = module.azure_attack_sim.deployment_summary
}

output "keyvault_name" {
  value = module.azure_attack_sim.keyvault_name
}

output "function_app_name" {
  value = module.azure_attack_sim.function_app_name
}

 output "ssh_connection_command" {
  value = module.azure_attack_sim.ssh_connection_command
}

output "vm_public_ip" {
  value = module.azure_attack_sim.vm_public_ip
}
```

### Variables

| Variable | Required | Default | Description |
|----------|----------|---------|-------------|
| `subscription_id` | Yes | - | Azure subscription ID |
| `client_name` | Yes | - | Client name (3-8 chars, lowercase alphanumeric) |
| `location` | No | `eastus` | Azure region |
| `vm_size` | No | `Standard_B2s` | VM size |
| `function_app_sku` | No | `B1` | Function App SKU (B1, S1, P1v2, Y1) |
| `admin_username` | No | `azureuser` | VM username |
| `admin_password` | No | `null` | VM password (12+ chars, uppercase, lowercase, number, special) |
| `vnet_address_space` | No | `["10.0.0.0/16"]` | VNet address space |
| `subnet_address_prefix` | No | `["10.0.1.0/24"]` | Subnet address prefix |
| `allowed_ssh_source_ips` | No | `["0.0.0.0/0"]` | IPs allowed to SSH |

### What Gets Created

- Resource Group
- VNet, Subnet, NSG, Public IP, NIC
- Linux VM with system-assigned managed identity (password auth)
- IAM role assignments (Reader, Contributor, User Access Admin, Graph API)
- Key Vault, Storage Account, Function App, Target Service Principal

---

## Option B: Bring-Your-Own-VM (Provided Infrastructure)

Use this when the client already has a VM with a managed identity and wants the module to create only the attack target resources.

### Prerequisites (Client Side)

Before running Terraform, the client must have:

1. **A Resource Group** with a known name and location
2. **A VM** with **system-assigned managed identity enabled**
   - Enable in Azure Portal: VM > Identity > System assigned > Status: **On**
3. **A Subnet** (for Key Vault network ACL)
4. The following values ready:

| Value Needed | How to Get It |
|-------------|---------------|
| Resource Group name | Azure Portal or `az group show` |
| Resource Group location | Azure Portal or `az group show --query location` |
| Subnet ID | `az network vnet subnet show --vnet-name <vnet> -g <rg> -n <subnet> --query id -o tsv` |
| VM Principal ID | `az vm show --name <vm> -g <rg> --query "identity.principalId" -o tsv` |

### Configuration

```hcl
module "azure_attack_sim" {
  source  = "cyngularsecurity/attack-simulation/azure"

  # Required
  subscription_id = "your-subscription-id"
  client_name     = "clientb"

  # Bring-your-own-VM settings
  create_vm                        = false
  existing_resource_group_name     = "my-existing-rg"
  existing_resource_group_location = "eastus"
  existing_subnet_id               = "/subscriptions/<sub-id>/resourceGroups/<rg>/providers/Microsoft.Network/virtualNetworks/<vnet>/subnets/<subnet>"
  existing_vm_principal_id         = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"

  # Set to false if the VM already has Reader/Contributor/UAA roles assigned
  assign_vm_roles = true
}

output "deployment_summary" {
  value = module.azure_attack_sim.deployment_summary
}

output "keyvault_name" {
  value = module.azure_attack_sim.keyvault_name
}

output "function_app_name" {
  value = module.azure_attack_sim.function_app_name
}
```

### Variables

| Variable | Required | Default | Description |
|----------|----------|---------|-------------|
| `subscription_id` | Yes | - | Azure subscription ID |
| `client_name` | Yes | - | Client name (3-8 chars, lowercase alphanumeric) |
| `create_vm` | Yes | - | Must be set to `false` |
| `existing_resource_group_name` | Yes | - | Name of the client's resource group |
| `existing_resource_group_location` | Yes | - | Location/region of the resource group |
| `existing_subnet_id` | Yes | - | Full resource ID of the subnet |
| `existing_vm_principal_id` | Yes | - | Managed identity principal ID of the VM |
| `assign_vm_roles` | No | `true` | Set to `false` if roles already exist on the VM |
| `function_app_sku` | No | `B1` | Function App SKU |

### What Gets Created

- Key Vault (deployed into the client's resource group)
- Storage Account
- Function App
- Target Service Principal
- IAM role assignments (unless `assign_vm_roles = false`)

### What Is NOT Created

- Resource Group, VNet, Subnet, NSG, Public IP, NIC, VM

### .env Output

When using `create_vm = false`, VM-related fields in the `.env` output will show `N/A` since the client manages those:

```
AZURE_VM_PUBLIC_IP=N/A
AZURE_VM_USERNAME=N/A
AZURE_VM_NAME=N/A
```

Put the existing values to them

---

## Usage

### 1. Initialize Terraform

```bash
terraform init
```

### 2. Review the Plan

```bash
terraform plan
```

### 3. Apply the Configuration

```bash
terraform apply
```

Type `yes` to confirm.

### 4. Get Outputs

```bash
terraform output
terraform output deployment_summary
terraform output -raw env_file_content
```

### 5. Connect to VM

```bash
ssh azureuser@<PUBLIC_IP>
```

## Function App SKU Options

| SKU | Filesystem | VFS Attacks | Notes |
|-----|-----------|-------------|-------|
| `B1` (Basic) | Writable | Supported | Default, good for testing |
| `S1` (Standard) | Writable | Supported | Production-grade |
| `P1v2` (Premium) | Writable | Supported | High performance |
| `Y1` (Consumption) | Read-only | Not supported | Cheapest option |

If you get `Basic tier is not allowed in this subscription`, use `Y1` or `S1`.

## Project Structure

```
azure-attack-simulation/
├── examples/                # Example root module configuration
├── .gitignore               # Git ignore rules
├── README.md                # This file
├── main.tf                  # Provider configuration
├── data.tf                  # Data sources
├── locals.tf                # Random suffix + naming logic
├── variables.tf             # Module input variables
├── resource_group.tf        # Resource group (conditional)
├── network.tf               # VNet, Subnet, NSG, Public IP (conditional)
├── vm.tf                    # Attack VM with managed identity (conditional)
├── iam.tf                   # RBAC role assignments (conditional)
├── target_resources.tf      # Key Vault, Storage, Function App
├── attack_targets.tf        # Target Service Principal
└── outputs.tf               # Module outputs
```

## Generated Files (Git-Ignored)

These files contain sensitive data:
- `terraform.tfstate` - Terraform state
- `.env` - Environment variables
- `func_deploy/` - Function deployment files
- `function.zip` - Packaged function code

## Cleanup

To destroy all resources:

```bash
terraform destroy
```

## Troubleshooting

### Role Assignment Already Exists (409 Conflict)
If the VM already has the required role assignments, set:
```hcl
assign_vm_roles = false
```

### Enterprise Subscription Restrictions
If Basic (B1) tier is not allowed:
```hcl
function_app_sku = "Y1"  # or "S1"
```
