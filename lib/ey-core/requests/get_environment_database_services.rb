
class Ey::Core::Client
  class Real
    def get_environment_database_services(params={})
      params["url"] || (environment_id = require_parameters(params, "environment_id"))

      request(
        :path => "/environments/#{environment_id}/database-services",
        :url  => params["url"],
      )
    end
  end # Real

  class Mock
    def get_environment_database_services(params={})
      require_parameters(params, "environment_id")

      get_database_services(params)
    end
  end # Mock
end
