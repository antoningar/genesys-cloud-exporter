resource "genesyscloud_outbound_contact_list" "contact-list" {
  name              = "exporter contact list"
  column_names      = ["number"]
  contacts_filepath = "./contactlist.csv"
  contacts_id_name  = "id"
  division_id       = genesyscloud_auth_division.exporter_division.id
  phone_columns {
    column_name = "number"
    type        = "cell"
  }
}
