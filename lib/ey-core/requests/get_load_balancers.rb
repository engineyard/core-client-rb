class Ey::Core::Client
  class Real
    def get_load_balancers(params={})
      query = Ey::Core.paging_parameters(params)
      url   = params.delete("url")

      request(
        :params => params,
        :query  => query,
        :path   => "/load-balancers",
        :url    => url,
      )
    end
  end # Real

  class Mock
    def get_load_balancers(params={})
      extract_url_params!(params)

      headers, load_balancers_page = search_and_page(params, :load_balancers, search_keys: %w[name])

      response(
        :body    => {"load_balancers" => load_balancers_page},
        :status  => 200,
        :headers => headers
      )
    end
  end # Mock
end
