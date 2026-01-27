# Azure Penetration Testing - Terraform Configuration

This Terraform configuration automates the setup of Azure resources for penetration testing.

## Prerequisites

1. **Terraform** installed (version >= 1.0)
2. **Azure CLI** installed and authenticated (`az login`)
3. Appropriate Azure subscription permissions

## 🔧 Prerequisites

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

## Configuration

### Module Structure

``` hcl

# Deploy Penetration Testing Infrastructure
module "azure_pentest" {
  source = "./modules/azure-pentest"

  # Required Configuration
  subscription_id = var.subscription_id  # Get with: az account show --query id -o tsv

  # Basic Configuration
  resource_group_name = var.resource_group_name  # Container for all resources
  location            = var.location              # Azure region (e.g., eastus, westus2)
  vm_name             = var.vm_name               # VM name
  vm_size             = var.vm_size               # VM size (Standard_B2s recommended)
  admin_username      = var.admin_username        # SSH username

  # Network Configuration
  vnet_address_space     = var.vnet_address_space      # VNet CIDR (e.g., ["10.0.0.0/16"])
  subnet_address_prefix  = var.subnet_address_prefix   # Subnet CIDR (e.g., ["10.0.1.0/24"])
  allowed_ssh_source_ips = var.allowed_ssh_source_ips  # Your IP only! 

  # Target Resources (must be globally unique)
  keyvault_name         = var.keyvault_name          # 3-24 chars, alphanumeric + hyphens
  storage_account_name  = var.storage_account_name   # 3-24 chars, lowercase alphanumeric only
  function_storage_name = var.function_storage_name  # 3-24 chars, lowercase alphanumeric only
  function_app_name     = var.function_app_name      # Globally unique function name
}
```


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

You'll be prompted to confirm. Type `yes` to proceed.

### 4. Get Outputs

After successful deployment, retrieve important information:

```bash
# Get all outputs
terraform output

# Get specific output
terraform output vm_public_ip
terraform output ssh_connection_command

```

### Generated Files (Git-ignored)

These files contain sensitive data and should **never** be committed:
- `azure_attack.pem` - SSH private key
- `azure_attack.pub` - SSH public key
- `.env` - Environment variables

### 5. Connect to VM

```bash
# SSH command will be shown in outputs
ssh -i ./azure_attack.pem azureuser@<PUBLIC_IP>
```

## Project Structure

```
azure-pentest-terraform/
├── main.tf                          # Root Terraform configuration
├── variables.tf                     # Root variables
├── outputs.tf                       # Root outputs
├── .gitignore                       # Git ignore rules
├── README.md                        # This file
├── modules/
│   └── azure-pentest/               # Main module
│       ├── main.tf                  # Module configuration
│       ├── resource_group.tf        # Resource group
│       ├── network.tf               # Networking resources
│       ├── vm.tf                    # Virtual machine
│       ├── ssh_keys.tf              # SSH key generation
│       ├── iam.tf                   # RBAC roles
│       ├── target_resources.tf      # Key Vault, Storage, Functions
│       ├── attack_targets.tf        # Service Principal
│       ├── variables.tf             # Module variables
│       └── outputs.tf               # Module outputs

```

## Cleanup

To destroy all resources:

```bash
terraform destroy
```

This will:
1. Remove all Azure resources
2. Delete the Key Vault
3. Delete local SSH key files


## Troubleshooting

### SSH Permission Errors
Ensure the private key has correct permissions:
```bash
chmod 600 ./azure_attack.pem
```
