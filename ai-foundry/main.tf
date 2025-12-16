resource "azurerm_ai_foundry" "ai_foundry" {
  name                = "ai-foundry-${var.application_name}-${var.location}"
  location            = var.location
  resource_group_name = var.resource_group_name
  storage_account_id  = var.storage_account_id
  key_vault_id        = var.key_vault_id
  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_cognitive_account" "cognitive_account" {
  name                = "cog-account-${var.application_name}-${var.location}"
  location            = var.location
  resource_group_name = var.resource_group_name
  kind                = "OpenAI"
  sku_name            = "S0"
}
## create an LLM Model for consumption and add its keys in key vault
resource "azurerm_cognitive_deployment" "llm_model" {
  name                 = "llm-model-${var.application_name}-${var.location}"
  cognitive_account_id = azurerm_cognitive_account.cognitive_account.id
  model {
    format = "OpenAI"
    name   = "gpt-4.1-mini"
  }
  sku {
    name     = "Standard"
    capacity = 1
  }
}
