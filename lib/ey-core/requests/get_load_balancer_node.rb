class Ey::Core::Client
  class Real
    def get_load_balancer_nodes(params={})
      id  = params["id"]
      url = params["url"]

      request(
        :path => "/load-balancer-nodes/#{id}",
        :url  => url,
      )
    end
  end # Real

  class Mock
    def get_load_balancer_nodes(params={})
      response(
        :body => {"load_balancer_node" => self.find(:load_balancer_nodes, resource_identity(params))},
      )
    end
  end # Mock
end # Ey::Core::Client
