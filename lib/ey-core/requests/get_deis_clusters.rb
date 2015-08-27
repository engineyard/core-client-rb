class Ey::Core::Client
  class Real
    def get_deis_clusters(params={})
      query = Ey::Core.paging_parameters(params)
      url   = params.delete("url")

      request(
        :params => params,
        :query  => query,
        :path   => "/deis-clusters",
        :url    => url,
      )
    end
  end # Real

  class Mock
    def get_deis_clusters(params={})
      extract_url_params!(params)

      headers, deis_clusters_page = search_and_page(params, :deis_clusters, search_keys: %w[account name])

      response(
        :body    => {"deis_clusters" => deis_clusters_page},
        :status  => 200,
        :headers => headers
      )
    end
  end # Mock
end
