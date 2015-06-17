class Ey::Core::Client
  class Real
    def get_load_balancer_service(params={})
      id  = params["id"]
      url = params["url"]

      request(
        :path => "/load-balancer-services/#{id}",
        :url  => url,
      )
    end
  end # Real

  class Mock
    def get_load_balancer_service(params={})
      response(
        :body => {"load_balancer_service" => self.find(:load_balancer_services, resource_identity(params))},
      )
    end
  end # Mock
end # Ey::Core::Client
