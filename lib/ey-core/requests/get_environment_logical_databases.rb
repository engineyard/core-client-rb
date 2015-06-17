class Ey::Core::Client
  class Real
    def get_environment_logical_databases(params={})
      params["url"] || (environment_id = require_parameters(params, "environment_id"))

      request(
        :path => "/environments/#{environment_id}/logical-databases",
        :url  => params["url"],
      )
    end
  end # Real

  class Mock
    def get_environment_logical_databases(params={})
      require_parameters(params, "environment_id")

      get_logical_databases(params)
    end
  end # Mock
end
