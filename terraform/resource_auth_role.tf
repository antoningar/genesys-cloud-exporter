resource "genesyscloud_auth_role" "function_exporter_role" {
  name        = "Custom Exporter Function Role"
  description = "Custom Role for exporter function"
  permission_policies {
    domain      = "analytics"
    entity_name = "agentConversationDetail"
    action_set  = ["view"]
  }
  permission_policies {
    domain      = "analytics"
    entity_name = "conversationDetail"
    action_set  = ["view"]
  }
  permission_policies {
    domain      = "bridge"
    entity_name = "actions"
    action_set  = ["view"]
  }
  permission_policies {
    domain      = "architect"
    entity_name = "flow"
    action_set  = ["launch"]
  }
}