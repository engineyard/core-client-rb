class Ey::Core::Client
  class Real
    def get_cluster_component(params={})
      id  = params["id"]
      url = params["url"]

      request(
        :path => "cluster-components/#{id}",
        :url  => url,
      )
    end
  end # Real

  class Mock
    def get_cluster_component(params={})
      response(
        :body => {"cluster_component" => self.find(:cluster_components, resource_identity(params))},
      )
    end
  end # Mock
end # Ey::Core::Client
