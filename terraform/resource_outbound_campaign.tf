resource "genesyscloud_outbound_campaign" "exoporter_campaign" {
  name            = "Exporter Campaign"
  dialing_mode    = "external"
  caller_name     = ""
  caller_address  = ""
  contact_list_id = genesyscloud_outbound_contact_list.contact-list.id
  campaign_status = "on"
  queue_id        = genesyscloud_routing_queue.tmp_exporter_queue.id
  script_id       = data.genesyscloud_script.default_script.id
  phone_columns {
    column_name = "number"
  }
}