class Ey::Core::Client
  class Real
    def update_cluster(params={})
      id = params.delete("id")
      request(
        :method => :put,
        :path   => "/clusters/#{id}",
        :body   => params,
      )
    end
  end

  class Mock
    def update_cluster(params={})
      identity = resource_identity(params)
      cluster  = find(:clusters, identity)

      update_params = Cistern::Hash.slice(params["cluster"], "release_label", "configuration")

      # core api doesn't actually do this yet
      if config = update_params.delete("configuration")
        update_params["configuration"] = normalize_hash(config)
      end

      cluster.merge!(update_params)

      response(
        :body => { "cluster" => cluster },
        :status => 200
      )
    end
  end
end
