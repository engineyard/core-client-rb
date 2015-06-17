class Ey::Core::Client::DatabaseServices < Ey::Core::Collection

  model Ey::Core::Client::DatabaseService

  self.model_root         = "database_service"
  self.model_request      = :get_database_service
  self.collection_root    = "database_services"
  self.collection_request = :get_database_services
end
