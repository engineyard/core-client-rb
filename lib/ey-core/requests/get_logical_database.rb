class Ey::Core::Client
  class Real
    def get_logical_database(params={})
      params["url"] || (id = require_parameters(params, "id"))

      request(
        :path => "/logical-databases/#{id}",
        :url  => params["url"],
      )
    end
  end

  class Mock
    def get_logical_database(params={})
      logical_database = self.find(:logical_databases, resource_identity(params))

      response(
        :body   => {"logical_database" => logical_database},
        :status => 200,
      )
    end
  end
end
