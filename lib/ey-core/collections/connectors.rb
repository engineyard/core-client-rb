class Ey::Core::Client::Connectors < Ey::Core::Collection

  model Ey::Core::Client::Connector

  self.model_root         = "connector"
  self.model_request      = :get_connector
  self.collection_root    = "connectors"
  self.collection_request = :get_connectors
end
