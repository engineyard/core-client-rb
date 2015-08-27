class Ey::Core::Client
  class Real
    def get_deis_cluster(params={})
      params["url"] || (id = params.fetch("id"))

      request(
        :path => "/deis-clusters/#{id}",
        :url  => params["url"],
      )
    end
  end # Real

  class Mock
    def get_deis_cluster(params={})
      response(
        :body => {"deis_cluster" => self.find(:deis_clusters, resource_identity(params))},
      )
    end
  end # Mock
end # Ey::Core::Client
