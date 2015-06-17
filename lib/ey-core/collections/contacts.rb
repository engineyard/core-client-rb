class Ey::Core::Client::Contacts < Ey::Core::Collection

  model Ey::Core::Client::Contact

  self.model_root         = "contact"
  self.model_request      = :get_contact
  self.collection_root    = "contacts"
  self.collection_request = :get_contacts
end
