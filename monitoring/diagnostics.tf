locals {
  services = {
    ingestion  = azurerm_container_app.ingestion.id
    packaging  = azurerm_container_app.packaging.id
    scheduler  = azurerm_container_app.scheduler.id
    delivery   = azurerm_container_app.delivery.id
  }
}

resource "azurerm_monitor_diagnostic_setting" "diagnostics" {
  for_each                   = local.services
  name                       = "diag-${each.key}"
  target_resource_id         = each.value
  log_analytics_workspace_id = azurerm_log_analytics_workspace.logs.id

  metric {
    category = "AllMetrics"
    enabled  = true

    retention_policy {
      enabled = false
    }
  }

  log {
    category = "ContainerAppConsoleLogs"
    enabled  = true

    retention_policy {
      enabled = false
    }
  }
}