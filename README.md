# Azure Attack Simulation - Terraform Configuration

This Terraform configuration automates the setup of Azure resources for attack simulation.

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


```hcl
# main.tf (root)
module "azure_attack_sim" {
  source = "cyngularsecurity/attack-simulation/azure"

  # Required
  subscription_id = var.subscription_id
  client_name     = var.client_name  # 3-8 chars, lowercase alphanumeric

  # Optional (with defaults)
  location               = var.location                # Default: "eastus"
  vm_size                = var.vm_size                 # Default: "Standard_B2s"
  admin_username         = var.admin_username          # Default: "azureuser"
  vnet_address_space     = var.vnet_address_space      # Default: ["10.0.0.0/16"]
  subnet_address_prefix  = var.subnet_address_prefix   # Default: ["10.0.1.0/24"]
  allowed_ssh_source_ips = var.allowed_ssh_source_ips  # Default: ["0.0.0.0/0"] - CHANGE THIS!
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
azure-attack-simulation/
├── examples                 # Example configuration you can use for module call
├── .gitignore               # Git ignore rules
├── README.md                # This file
├── main.tf                  # Provider configuration
├── data.tf                  # Data sources
├── locals.tf                # Random suffix + naming logic
├── variables.tf             # Module input variables
├── resource_group.tf        # Resource group
├── network.tf               # VNet, Subnet, NSG, Public IP
├── ssh_keys.tf              # SSH key generation
├── vm.tf                    # Attack VM with managed identity
├── iam.tf                   # RBAC role assignments
├── target_resources.tf      # Key Vault, Storage, Function App
├── attack_targets.tf        # Target Service Principal
└── outputs.tf               # Module outputs
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
