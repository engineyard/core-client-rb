class Ey::Core::Client
  class Real
    def create_database_service_snapshot(params={})
      (url = params.delete("url")) || (name = params.fetch("name"))

      request(
        :method => :post,
        :path   => "/database-services/#{name}/snapshot",
        :url    => url,
        :body   => params,
      )
    end
  end

  class Mock
    def create_database_service_snapshot(_params={})
      params = Cistern::Hash.stringify_keys(_params)

      server_or_service_id = resource_identity(params["url"]) || require_parameters(params, "database_service")

      database_service = if (database_server = self.data[:database_servers][server_or_service_id])
                           find(:database_services, resource_identity(database_server["database_service"]))
                         else
                           find(:database_services, database_service_id)
                         end

      database_server ||= self.data[:database_servers].values.find { |ds| url_for("/database-services/#{database_service["id"]}") == ds["database_service"] }
      database_service_id = database_service["id"]

      find(:database_services, database_service_id)

      request_id  = self.uuid
      resource_id = self.uuid

      resource = {
        "id"                => resource_id,
        "created_at"        => Time.now.to_s,
        "updated_at"        => Time.now.to_s,
        "resource_url"      => url_for("/database-server-snapshots/#{resource_id}"),
        "provisioned_id"    => params["name"] || "rds:#{database_server["provisioned_id"]}-#{Time.now.strftime("%Y-%M-%D-%H")}",
        "database_server"   => url_for("/database-servers/#{database_server["id"]}"),
        "database_service"  => url_for("/database-services/#{database_service_id}"),
        "provider"          => database_service["provider"],
        "provisioned_at"    => Time.now.to_s,
        "logical_databases" => url_for("database-server-snapshots/#{resource_id}/logical-databases"),
      }.merge(Cistern::Hash.slice(database_server, "storage", "engine", "engine_version"))

      request = {
        "id"           => request_id,
        "type"         => "provision_database_server_snapshot",
        "successful"   => "true",
        "started_at"   => Time.now,
        "finished_at"  => nil,
        "resource_url" => url_for("/database-server-snapshots/#{resource_id}"),
        "resource"     => [:database_server_snapshots, resource_id, resource],
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
