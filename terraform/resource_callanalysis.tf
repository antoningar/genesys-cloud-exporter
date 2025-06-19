resource "genesyscloud_outbound_callanalysisresponseset" "exporter_analysis" {
  name                   = "Exporter analysis"
  beep_detection_enabled = false
  responses {
    callable_person {
      name          = "Example Outbound Flow"
      data          = genesyscloud_flow.outbound_flow.id
      reaction_type = "transfer_flow"
    }
  }
}