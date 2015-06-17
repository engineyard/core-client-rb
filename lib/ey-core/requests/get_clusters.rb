class Ey::Core::Client
  class Real
    def get_clusters(params={})
      query = Ey::Core.paging_parameters(params)
      url   = params.delete("url")

      request(
        :params => params,
        :query => query,
        :path  => "/clusters",
        :url   => url,
      )
    end
  end # Real
  class Mock
    def get_clusters(params={})
      extract_url_params!(params)

      if firewall_id = resource_identity(params.delete("firewall"))
        self.find(:firewalls, firewall_id)

        cluster_ids = self.data[:cluster_firewalls].select { |_, fid| firewall_id == fid }.map { |cid, _| cid }

        params["id"] = cluster_ids
      end

      headers, clusters_page = search_and_page(params, :clusters, search_keys: %w[name environment id])

      response(
        :body    => {"clusters" => clusters_page},
        :headers => headers
      )
    end
  end # Mock
end
