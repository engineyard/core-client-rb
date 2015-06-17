class Ey::Core::Client
  class Real
    def get_cluster_components(params={})
      query = Ey::Core.paging_parameters(params)
      url   = params.delete("url")

      request(
        :params => params,
        :query  => query,
        :path   => "/cluster-components",
        :url    => url,
      )
    end
  end # Real
  class Mock
    def get_cluster_components(params={})
      extract_url_params!(params)

      headers, cluster_components_page = search_and_page(params, :cluster_components, search_keys: %w[cluster component])

      response(
        :body    => {"cluster_components" => cluster_components_page},
        :status  => 200,
        :headers => headers
      )
    end
  end # Mock
end
