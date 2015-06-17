class Ey::Core::Client
  class Real
    def get_features(params={})
      query = Ey::Core.paging_parameters(params)
      url   = params.delete("url")

      request(
        :params => params,
        :query  => query,
        :path   => "/features",
        :url    => url,
      )
    end
  end # Real

  class Mock
    def get_features(params={})
      extract_url_params!(params)

      headers, features_page = search_and_page(params, :features, search_keys: %w[account id privacy])

      response(
        :body    => {"features" => features_page},
        :headers => headers
      )
    end
  end # Mock
end # Ey::Core::Client
