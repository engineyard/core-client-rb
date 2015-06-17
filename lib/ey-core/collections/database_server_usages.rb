class Ey::Core::Client::DatabaseServerUsages < Ey::Core::Collection

  model Ey::Core::Client::DatabaseServerUsage

  self.collection_root    = "database_server_usages"
  self.collection_request = :get_database_server_usages
end
