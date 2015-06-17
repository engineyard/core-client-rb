class Ey::Core::Client
  class Real
    def discover_database_server_snapshots(params={})
      url      = params.delete("url")
      provider = params.delete("provider")

      request(
        :method => :post,
        :url    => url,
        :params => params,
        :path   => "/providers/#{provider}/database-server-snapshots/discover",
      )
    end
  end

  class Mock
    def discover_database_server_snapshots(params={})
      extract_url_params!(params)

      provider     = params.delete('provider')
      resource_id  = self.uuid
      request_id   = self.uuid
      provider_url = url_for("/providers/#{provider}")

      existing_snapshots = self.data[:database_server_snapshots].values.select { |dss| dss["provider"] == provider_url }
      database_server    = self.data[:database_servers].values.detect { |ds| ds["provider"] == provider_url }

      resources = if existing_snapshots.empty?
                    if database_server
                      [{
                        "id"              => resource_id,
                        "location"        => database_server["location"],
                        "engine"          => database_server["engine"],
                        "engine_version"  => database_server["version"],
                        "storage"         => database_server["storage"],
                        "provisioned_id"  => resource_id,
                        "provisioned_at"  => Time.now - 3600,
                        "provider"        => provider_url,
                        "database_server" => url_for("/database-servers/#{database_server["id"]}")
                      }]
                    else []
                    end
                  else existing_snapshots
                  end

      request = {
        "id" => request_id,
        "type" => "discover_database_server_snapshots",
        "successful" => true,
        "started_at" => Time.now,
        "finished_at" => nil,
        "resource" => [:database_server_snapshots, resource_id, resources, "providers/#{provider}/database-server-snapshots"]
      }

      self.data[:requests][request_id] = request

      response_hash = request.dup
      response_hash.delete("resource")

      response(
        :body    => {"request" => response_hash},
        :status  => 200,
        :headers => {
          "Content-Type" => "application/json; charset=utf8"
        }
      )
    end
  end
end
