class Ey::Core::Client
  class Real
    def get_application_deployment(params={})
      id  = params["id"]
      url = params["url"]

      request(
        :path => "application-deployments/#{id}",
        :url  => url
      )
    end
  end # Real

  class Mock
    def get_application_deployment(params={})
      response(
        :body => {"application_deployment" => self.find(:application_deployments, resource_identity(params))},
      )
    end
  end # Mock
end # Ey::Core::Client
