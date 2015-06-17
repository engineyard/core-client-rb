class Ey::Core::Client::DatabaseServerRevisions < Ey::Core::Collection

  model Ey::Core::Client::DatabaseServerRevision

  self.collection_root    = "database_server_revisions"
  self.collection_request = :get_database_server_revisions
end
