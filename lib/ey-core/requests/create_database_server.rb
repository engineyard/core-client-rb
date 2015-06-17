class Ey::Core::Client
  class Real
    def create_database_server(params={})
      request(
        :method => :post,
        :path   => "/database-servers",
        :url    => params.delete("url"),
        :body   => params,
      )
    end
  end

  class Mock
    def create_database_server(_params={})
      params = Cistern::Hash.stringify_keys(_params)

      require_parameters(params, "provider")
      require_parameters(params["database_server"], "replication_source")

      request_id  = self.uuid
      resource_id = self.uuid

      provider_id = resource_identity(params["provider"])
      find(:providers, provider_id)

      replication_source_id = resource_identity(params["database_server"]["replication_source"])
      replication_source    = find(:database_servers, replication_source_id)

      resource = {
        "id"                 => resource_id,
        "resource_url"       => url_for("/database-servers/#{resource_id}"),
        "provisioned_id"     => "replica-#{SecureRandom.hex(3)}",
        "engine"             => replication_source["engine"],
        "version"            => replication_source["version"],
        "storage"            => replication_source["storage"],
        "modifiers"          => replication_source["modifiers"],
        "endpoint"           => replication_source["endpoint"],
        "flavor"             => replication_source["flavor"],
        "location"           => replication_source["location"],
        "deleted_at"         => nil,
        "database_service"   => replication_source["database_service"],
        "replication_source" => url_for("/database-servers/#{replication_source_id}"),
        "alerts"             => url_for("/database-servers/#{resource_id}/alerts"),
        "firewalls"          => url_for("/database-servers/#{resource_id}/firewalls"),
        "provider"           => url_for("/providers/#{provider_id}"),
        "messages"           => url_for("/database-servers/#{resource_id}/messages"),
        "snapshots"          => url_for("/database-servers/#{resource_id}/snapshots"),
        "revisions"          => url_for("/database-servers/#{resource_id}/revisions"),
      }

      request = {
        "id"           => request_id,
        "type"         => "provision_database_server",
        "successful"   => "true",
        "started_at"   => Time.now,
        "finished_at"  => nil,
        "resource_url" => url_for("/database-servers/#{resource_id}"),
        "resource"     => [:database_servers, resource_id, resource],
      }

      self.data[:requests][request_id] = request

      response_hash = request.dup
      response_hash.delete("resource")

      response(
        :body    => {"request" => response_hash},
        :status  => 201,
      )
    end
  end
end
