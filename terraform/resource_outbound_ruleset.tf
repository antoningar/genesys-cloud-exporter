resource "genesyscloud_outbound_ruleset" "exporter_outbound_ruleset" {
  name            = "exporter_outbound_ruleset"
  contact_list_id = genesyscloud_outbound_contact_list.contact-list.id
  rules {
    name     = "exporter_outbound_rule"
    order    = 0
    category = "DIALER_PRECALL"
    conditions {
      type           = "contactAttributeCondition"
      attribute_name = "number"
      value_type     = "STRING"
      operator       = "CONTAINS"
      value          = "0"
    }
    actions {
      type             = "Action"
      action_type_name = "DO_NOT_DIAL"
    }
    actions {
      type             = "dataActionBehavior"
      action_type_name = "DATA_ACTION"
      data_action_id   = genesyscloud_integration_action.execute_exporter_workflow.id
    }
  }
}