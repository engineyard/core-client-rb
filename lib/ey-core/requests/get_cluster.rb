class Ey::Core::Client
  class Real
    def get_cluster(params={})
      id  = params["id"]
      url = params["url"]

      request(
        :path => "/clusters/#{id}",
        :url  => url,
      )
    end
  end # Real

  class Mock
    def get_cluster(params={})
      response(
        :body   => {"cluster" => self.find(:clusters, resource_identity(params))},
      )
    end
  end # Mock
end # Ey::Core::Client
