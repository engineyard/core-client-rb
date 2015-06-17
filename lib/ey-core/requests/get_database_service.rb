class Ey::Core::Client
  class Real
    def get_database_service(params={})
      params["url"] || (id = require_parameters(params, "id"))

      request(
        :path => "/database-services/#{id}",
        :url  => params["url"],
      )
    end
  end

  class Mock
    def get_database_service(params={})
      response(
        :body => {"database_service" => self.find(:database_services, resource_identity(params))},
      )
    end
  end
end
