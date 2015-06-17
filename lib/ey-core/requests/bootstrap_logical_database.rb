class Ey::Core::Client
  class Real
    def bootstrap_logical_database(params={})
      request(
        :method => :post,
        :path   => "/logical-databases/bootstrap",
        :url    => params.delete("url"),
        :body   => params,
      )
    end
  end

  class Mock
    def bootstrap_logical_database(_params={})
      params = Cistern::Hash.stringify_keys(_params)
      provider_id = resource_identity(params["provider"])
      find(:providers, provider_id)

      logical_database_name = require_parameters(params["logical_database"], "name")
      request_id  = self.uuid
      resource_id = self.uuid

      database_service = params["database_service"]

      if database_service.is_a?(Hash)
        require_parameters(params["database_service"], "name")
        database_service["id"] = self.serial_id
      else
        database_service = find(:database_services, database_service)
        existing_database_service = true
      end

      resource = {
        "username"     => "eyuser#{SecureRandom.hex(4)}",
        "password"     => SecureRandom.hex(16),
        "name"         => logical_database_name,
        "id"           => resource_id,
        "resource_url" => "/logical-databases/#{resource_id}",
        "service"      => url_for("/database-services/#{database_service.fetch("id")}"),
        "deleted_at"   => nil,
      }

      request_resource = if existing_database_service
                           { "resource" => [:logical_databases, resource_id, resource] }
                         else
                           {
                             "resource" => [
                               :logical_databases,
                               request_id,
                               create_database_service_resource(
                                 "logical_database" => resource,
                                 "database_service" => database_service,
                                 "database_server"  => params["database_server"].dup,
                                 "provider_id"      => provider_id,
                               )
                             ],
                           }
                         end

      request = {
        "id"           => request_id,
        "type"         => "bootstrap_logical_database",
        "successful"   => "true",
        "started_at"   => Time.now,
        "finished_at"  => nil,
        "resource_url" => "/logical-databases/#{resource_id}",
      }.merge(request_resource)

      self.data[:requests][request_id] = request

      response_hash = request.dup
      response_hash.delete("resource")

      response(
        :body   => {"request" => response_hash},
        :status => 201,
      )
    end
  end
end
