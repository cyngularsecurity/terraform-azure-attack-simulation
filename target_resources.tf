resource "azurerm_key_vault" "attack_sim" {
  name                          = local.keyvault_name
  resource_group_name           = azurerm_resource_group.attack_sim.name
  location                      = azurerm_resource_group.attack_sim.location
  tenant_id                     = data.azurerm_client_config.current.tenant_id
  sku_name                      = "standard"
  rbac_authorization_enabled    = true
  public_network_access_enabled = false
  purge_protection_enabled      = false
  soft_delete_retention_days    = 7

  network_acls {
    bypass         = "AzureServices"
    default_action = "Deny"

    virtual_network_subnet_ids = [azurerm_subnet.attack_sim.id]
  }

  tags = local.common_tags
}

resource "azurerm_storage_account" "attack_sim" {
  name                     = local.storage_account_name
  resource_group_name      = azurerm_resource_group.attack_sim.name
  location                 = azurerm_resource_group.attack_sim.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = local.common_tags
}

resource "azurerm_storage_account" "function" {
  name                     = local.function_storage_name
  resource_group_name      = azurerm_resource_group.attack_sim.name
  location                 = azurerm_resource_group.attack_sim.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = local.common_tags
}

resource "azurerm_service_plan" "function" {
  name                = local.app_service_plan_name
  resource_group_name = azurerm_resource_group.attack_sim.name
  location            = azurerm_resource_group.attack_sim.location
  os_type             = "Linux"
  sku_name            = var.function_app_sku

  tags = local.common_tags
}

resource "azurerm_linux_function_app" "attack_sim" {
  name                       = local.function_app_name
  resource_group_name        = azurerm_resource_group.attack_sim.name
  location                   = azurerm_resource_group.attack_sim.location
  service_plan_id            = azurerm_service_plan.function.id
  storage_account_name       = azurerm_storage_account.function.name
  storage_account_access_key = azurerm_storage_account.function.primary_access_key

  identity {
    type = "SystemAssigned"
  }

  site_config {
    application_stack {
      python_version = "3.11"
    }

    cors {
      allowed_origins = ["*"]
    }
  }

  app_settings = {
    "FUNCTIONS_WORKER_RUNTIME"       = "python"
    "WEBSITE_RUN_FROM_PACKAGE"       = var.function_app_sku == "Y1" ? "1" : "0"
    "AzureWebJobsFeatureFlags"       = "EnableWorkerIndexing"
    "FUNCTIONS_EXTENSION_VERSION"    = "~4"
    "ENABLE_ORYX_BUILD"              = "true"
    "SCM_DO_BUILD_DURING_DEPLOYMENT" = "true"
  }

  tags = local.common_tags

  lifecycle {
    ignore_changes = [
      auth_settings,
      auth_settings_v2
    ]
  }
}

resource "local_file" "func_host" {
  content = jsonencode({
    version = "2.0"
    logging = {
      applicationInsights = {
        samplingSettings = {
          isEnabled = true
        }
      }
    }
    extensionBundle = {
      id      = "Microsoft.Azure.Functions.ExtensionBundle"
      version = "[4.*, 5.0.0)"
    }
  })
  filename = "${path.root}/func_deploy/host.json"
}

resource "local_file" "func_requirements" {
  content  = "azure-functions\n"
  filename = "${path.root}/func_deploy/requirements.txt"
}

resource "local_file" "func_python_code" {
  content  = <<-PYTHON
import azure.functions as func
import logging

app = func.FunctionApp()

@app.route(route="http_trigger", auth_level=func.AuthLevel.ANONYMOUS)
def http_trigger(req: func.HttpRequest) -> func.HttpResponse:
    logging.info('Python HTTP trigger function processed a request.')
    
    name = req.params.get('name')
    if not name:
        try:
            req_body = req.get_json()
        except ValueError:
            pass
        else:
            name = req_body.get('name')
    
    if name:
        return func.HttpResponse(
            f"Hello, {name}! This HTTP triggered function executed successfully.",
            status_code=200
        )
    else:
        return func.HttpResponse(
            "This HTTP triggered function executed successfully. Pass a name in the query string or request body for a personalized response.",
            status_code=200
        )
PYTHON
  filename = "${path.root}/func_deploy/function_app.py"
}

resource "local_file" "func_ignore" {
  content  = <<-IGNORE
.git*
.vscode
__pycache__
*.pyc
.python_packages
IGNORE
  filename = "${path.root}/func_deploy/.funcignore"
}

data "archive_file" "function_zip" {
  type        = "zip"
  source_dir  = "${path.root}/func_deploy"
  output_path = "${path.root}/function.zip"
  depends_on = [
    local_file.func_host,
    local_file.func_python_code,
    local_file.func_requirements,
    local_file.func_ignore
  ]
}

resource "terraform_data" "deploy_function_code" {
  triggers_replace = {
    src_hash = data.archive_file.function_zip.output_base64sha256
  }

  input = {
    resource_group = azurerm_resource_group.attack_sim.name
    function_name  = azurerm_linux_function_app.attack_sim.name
    zip_path       = data.archive_file.function_zip.output_path
    sku            = var.function_app_sku
  }

  provisioner "local-exec" {
    command = <<-EOT
      echo "Deploying function app via zip package (SKU: ${self.input.sku})..."
      az functionapp deployment source config-zip \
        --resource-group ${self.input.resource_group} \
        --name ${self.input.function_name} \
        --src ${self.input.zip_path}
      
      echo "Waiting for deployment to complete..."
      sleep 30
      
      echo "Restarting function app..."
      az functionapp restart \
        --resource-group ${self.input.resource_group} \
        --name ${self.input.function_name}
      
      echo "Waiting for restart..."
      sleep 20
      
      echo "Function app deployed successfully!"
      
      # Display filesystem mode based on SKU
      if [ "${self.input.sku}" = "Y1" ]; then
        echo "Note: Consumption plan - filesystem is READ-ONLY (WEBSITE_RUN_FROM_PACKAGE=1)"
        echo "VFS attacks are LIMITED on this plan. Consider S1/B1/P1v2/P1v3 for writable filesystem."
      else
        echo "Dedicated plan - filesystem is WRITABLE (WEBSITE_RUN_FROM_PACKAGE=0)"
        echo "VFS attacks are fully supported."
      fi
    EOT
  }
}
