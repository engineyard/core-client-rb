class Ey::Core::Client::DatabaseServerSnapshots < Ey::Core::Collection

  model Ey::Core::Client::DatabaseServerSnapshot

  self.model_root         = "database_server_snapshot"
  self.model_request      = :get_database_server_snapshot
  self.collection_root    = "database_server_snapshots"
  self.collection_request = :get_database_server_snapshots

  def discover(provider)
    params = {
      "provider" => provider.is_a?(Ey::Core::Client::Provider) ? provider.id : provider
    }

    connection.requests.new(connection.discover_database_server_snapshots(params).body["request"])
  end
end
