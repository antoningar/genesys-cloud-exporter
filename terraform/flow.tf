resource "genesyscloud_flow" "flow" {
  filepath          = "./Exporter_Orchestrator.yaml"
  file_content_hash = filesha256("./Exporter_Orchestrator.yaml")

  substitutions = {
    mails         = var.mails
    function_name = var.function_name
    integration   = genesyscloud_integration.exporter_function_integration.config[0].name
  }
}