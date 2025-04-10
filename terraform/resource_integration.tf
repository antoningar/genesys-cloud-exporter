resource "genesyscloud_integration" "exporter_function_integration" {
  intended_state   = "ENABLED"
  integration_type = "function-data-actions"
  config {
    name = "exporter function integration"
  }
  lifecycle {
    ignore_changes = [ config ]
  }
}