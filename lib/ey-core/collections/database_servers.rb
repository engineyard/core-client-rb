class Ey::Core::Client::DatabaseServers < Ey::Core::Collection

  model Ey::Core::Client::DatabaseServer

  self.model_root         = "database_server"
  self.model_request      = :get_database_server
  self.collection_root    = "database_servers"
  self.collection_request = :get_database_servers
end
