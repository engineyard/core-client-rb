class Ey::Core::Client
  class Real
    def create_database_service(params={})
      request(
        :method => :post,
        :path   => "/database-services",
        :url    => params.delete("url"),
        :body   => params,
      )
    end
  end

  class Mock
    def create_database_service(_params={})
      params = Cistern::Hash.stringify_keys(_params)

      require_parameters(params, "provider")
      provider_id = resource_identity(params["provider"])
      find(:providers, provider_id)

      require_parameters(params["database_service"], "name")
      request_id  = self.uuid
      resource_id = self.uuid

      database_service = params["database_service"].dup
      database_service["id"] = resource_id
      database_server = params["database_server"].dup
      database_server["storage"] ||= 50

      request_block = create_database_service_resource(
        "database_service" => database_service,
        "database_server"  => database_server,
        "provider_id"      => provider_id,
      )

      request = {
        "id"           => request_id,
        "type"         => "provision_database_service",
        "successful"   => "true",
        "started_at"   => Time.now,
        "finished_at"  => nil,
        "resource_url" => database_service["resource_url"],
        "resource"     => [:database_services, request_id, request_block],
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
