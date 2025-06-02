resource "genesyscloud_outbound_campaign" "exoporter_campaign" {
  name                          = "Exporter Campaign"
  dialing_mode                  = "agentless" //"external"
  caller_name                   = "exporter"
  caller_address                = "0600000000"
  contact_list_id               = genesyscloud_outbound_contact_list.contact-list.id
  campaign_status               = "on"
  always_running                = false
  script_id                     = data.genesyscloud_script.default_script.id
  rule_set_ids                  = [genesyscloud_outbound_ruleset.exporter_outbound_ruleset.id]
  call_analysis_response_set_id = genesyscloud_outbound_callanalysisresponseset.exporter_analysis.id
  edge_group_id                 = data.genesyscloud_telephony_providers_edges_edge_group.edgeGroup.id
  outbound_line_count           = 1
  phone_columns {
    column_name = "number"
  }
}