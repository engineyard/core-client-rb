class Ey::Core::Client::LogicalDatabases < Ey::Core::Collection

  model Ey::Core::Client::LogicalDatabase

  self.model_root         = "logical_database"
  self.model_request      = :get_logical_database
  self.collection_root    = "logical_databases"
  self.collection_request = :get_logical_databases


  def bootstrap(_params)
    params = Cistern::Hash.slice(_params, :provider, :database_service, :cluster_components, :logical_database, :database_server)

    connection.requests.new(self.connection.bootstrap_logical_database(params).body["request"])
  end
end
