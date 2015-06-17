class Ey::Core::Client
  class Real
    def get_cluster_updates(params={})
      query   = Ey::Core.paging_parameters(params)
      url     = params.delete("url")
      cluster = params.delete("cluster")
      path    = cluster ?  "/clusters/#{cluster}/updates" : "/cluster-updates"

      request(params: params, query: query, path: path, url: url)
    end
  end # Real

  class Mock
    def get_cluster_updates(params={})
      extract_url_params!(params)

      headers, cluster_updates_page = search_and_page(params, :cluster_updates, search_keys: %w[cluster])

      response(
        :body    => {"cluster_updates" => cluster_updates_page},
        :status  => 200,
        :headers => headers
      )
    end
  end # Mock
end
