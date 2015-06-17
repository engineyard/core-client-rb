class Ey::Core::Client
  class Real
    def get_keypair_deployment(params={})
      id  = params["id"]
      url = params["url"]

      request(
        :path => "keypair-deployments/#{id}",
        :url  => url,
      )
    end
  end # Real

  class Mock
    def get_keypair_deployment(params={})
      response(
        :body => {"keypair_deployment" => self.find(:keypair_deployments, resource_identity(params))},
      )
    end
  end # Mock
end # Ey::Core::Client
