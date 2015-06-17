class Ey::Core::Client
  class Real
    def get_cluster_update(params={})
      id  = params["id"]
      url = params["url"]

      request(
        :path => "cluster-updates/#{id}",
        :url  => url,
      )
    end
  end # Real

  class Mock
    def get_cluster_update(params={})
      response(
        :body => {"cluster_update" => self.find(:cluster_updates, resource_identity(params))},
      )
    end
  end # Mock
end # Ey::Core::Client
