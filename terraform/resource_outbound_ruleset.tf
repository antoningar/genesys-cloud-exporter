resource "genesyscloud_outbound_ruleset" "exporter_outbound_ruleset" {
  name            = "exporter_outbound_ruleset"
  contact_list_id = genesyscloud_outbound_contact_list.contact-list.id
  queue_id        = genesyscloud_routing_queue.tmp_exporter_queue.id
  rules {
    name     = "exporter_outbound_rule"
    order    = 0
    category = "DIALER_PRECALL"
    conditions {
      type           = "contactAttributeCondition" // Possible values: wrapupCondition, systemDispositionCondition, contactAttributeCondition, phoneNumberCondition, phoneNumberTypeCondition, callAnalysisCondition, contactPropertyCondition, dataActionCondition
      attribute_name = "number"
      value_type     = "STRING"   // Possible values: STRING, NUMERIC, DATETIME, PERIOD
      operator       = "CONTAINS" // Possible values: EQUALS, LESS_THAN, LESS_THAN_EQUALS, GREATER_THAN, GREATER_THAN_EQUALS, CONTAINS, BEGINS_WITH, ENDS_WITH, BEFORE, AFTER, IN
      value          = "0"
    }
    actions {
      type             = "Action"      // Possible values: Action, modifyContactAttribute, dataActionBehavior
      action_type_name = "DO_NOT_DIAL" // Possible values: DO_NOT_DIAL, MODIFY_CONTACT_ATTRIBUTE, SWITCH_TO_PREVIEW, APPEND_NUMBER_TO_DNC_LIST, SCHEDULE_CALLBACK, CONTACT_UNCALLABLE, NUMBER_UNCALLABLE, SET_CALLER_ID, SET_SKILLS, DATA_ACTION
    }
    actions {
      type             = "dataActionBehavior" // Possible values: Action, modifyContactAttribute, dataActionBehavior
      action_type_name = "DATA_ACTION"        // Possible values: DO_NOT_DIAL, MODIFY_CONTACT_ATTRIBUTE, SWITCH_TO_PREVIEW, APPEND_NUMBER_TO_DNC_LIST, SCHEDULE_CALLBACK, CONTACT_UNCALLABLE, NUMBER_UNCALLABLE, SET_CALLER_ID, SET_SKILLS, DATA_ACTION
      data_action_id   = genesyscloud_integration_action.execute_exporter_workflow.id
    }
  }
}