class Ey::Core::Client
  class Real
    def create_environment_variable(_params={})
      params = Cistern::Hash.stringify_keys(_params)
      environment_id = params.delete("environment_id")
      application_id = params.delete("application_id")
      body = { environment_variable: params, environment_id: environment_id, application_id: application_id }

      request(
        :method => :post,
        :path   => "/environment_variables",
        :body   => body
      )
    end
  end # Real

  class Mock
    def create_environment_variable(_params={})
      params = Cistern::Hash.stringify_keys(_params)

      resource_id = serial_id
      environment = find(:environments, params["environment_id"])
      application = find(:applications, params["application_id"])

      params["id"] = resource_id
      params["environment_name"] = environment["name"]
      params["environment"] = url_for("/environments/#{environment['id']}")
      params["application_name"] = application["name"]
      params["application"] = url_for("/applications/#{application['id']}")

      self.data[:environment_variables][resource_id] = params

      response(
        :body    => {"environment_variable" => params},
        :status  => 201,
      )
    end
  end # Mock
end # Ey::Core::Client
