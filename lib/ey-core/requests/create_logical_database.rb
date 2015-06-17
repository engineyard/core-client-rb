class Ey::Core::Client
  class Real
    def create_logical_database(params={})
      request(
        :method => :post,
        :path   => "/logical-databases",
        :url    => params.delete("url"),
        :body   => params,
      )
    end
  end

  class Mock
    def create_logical_database(_params={})
      params = Cistern::Hash.stringify_keys(_params)
      database_service_id = resource_identity(params["url"]) || require_parameters(params, "database_service")
      logical_database_name = require_parameters(params["logical_database"], "name")

      request_id  = self.uuid
      resource_id = self.serial_id

      find(:database_services, database_service_id)

      resource = {
        "name" => logical_database_name,
        "username" => "eyuser#{SecureRandom.hex(4)}",
        "password" => SecureRandom.hex(16),
      }.merge(params["logical_database"]).merge(
        "id"           => resource_id,
        "resource_url" => "/logical-databases/#{resource_id}",
        "service"      => url_for("/database-services/#{database_service_id}"),
        "deleted_at"   => nil,
        )

      request = {
        "id"           => request_id,
        "type"         => "provision_logical_database",
        "successful"   => "true",
        "started_at"   => Time.now,
        "finished_at"  => nil,
        "resource_url" => resource["resource_url"],
        "resource"     => [:logical_databases, resource_id, resource],
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
