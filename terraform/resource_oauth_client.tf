resource "genesyscloud_oauth_client" "integration_client" {
  name                          = "Exporter Integration Client"
  description                   = "Oauth client to allow exporter function to get genesys datas"
  access_token_validity_seconds = 86400
  authorized_grant_type         = "CLIENT-CREDENTIALS"
  roles {
    role_id     = genesyscloud_auth_role.function_exporter_role.id
    division_id = "*"
  }
}