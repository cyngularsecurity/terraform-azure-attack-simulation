# Azure Penetration Testing - Terraform Configuration

This Terraform configuration automates the setup of Azure resources for penetration testing.

## Prerequisites

1. **Terraform** installed (version >= 1.0)
2. **Azure CLI** installed and authenticated (`az login`)
3. Appropriate Azure subscription permissions

## What This Creates

- Resource Group
- Virtual Network and Subnet
- Network Security Group (with SSH access)
- Public IP Address
- Network Interface
- Virtual Machine (Ubuntu 22.04) with System-Assigned Managed Identity
- SSH Key Pair (RSA 4096-bit)
- Key Vault
- Storage Account
- Function App with dedicated storage
- IAM Role Assignments

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
