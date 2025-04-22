resource "genesyscloud_integration_action" "execute_exporter_workflow" {
  name           = "execute_exporter_workflow"
  category       = data.genesyscloud_integration.genesys_integration.name
  integration_id = data.genesyscloud_integration.genesys_integration.id
  contract_output = jsonencode(
    {
      "type" = "object",
      "properties" : {
        "blankStr" = {
          "type" = "string"
        },
      }
    }
  )
  contract_input = jsonencode(
    {
      "type" = "object",
      "properties" : {
        "blankStr" = {
          "type" = "string"
        },
      }
    }
  )
  config_request {
    request_url_template = "/api/v2/flows/executions"
    request_type         = "POST"
    request_template     = format("{\"flowId\":\"%s\" \"name\":\"action execute\"}", genesyscloud_flow.flow.id)
    headers = {
      Content-Type = "application/json"
    }
  }
  config_response {
    translation_map          = {}
    translation_map_defaults = {}
    success_template         = "{rawResult}"
  }
}