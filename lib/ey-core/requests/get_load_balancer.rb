class Ey::Core::Client
  class Real
    def get_load_balancer(params={})
      id  = params["id"]
      url = params["url"]

      request(
        :path => "/load-balancers/#{id}",
        :url  => url,
      )
    end
  end # Real

  class Mock
    def get_load_balancer(params={})
      response(
        :body => {"load_balancer" => self.find(:load_balancers, resource_identity(params))},
      )
    end
  end # Mock
end # Ey::Core::Client
