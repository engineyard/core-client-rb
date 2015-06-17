class Ey::Core::Client
  class Real
    def get_components(params={})
      query = Ey::Core.paging_parameters(params)
      url   = params.delete("url")

      request(
        :params => params,
        :query  => query,
        :path   => "/components",
        :url    => url,
      )
    end
  end # Real

  class Mock
    def get_components(params={})
      extract_url_params!(params)

      headers, components_page = search_and_page(params, :components, search_keys: %w[name id uri])

      response(
        :body    => {"components" => components_page},
        :status  => 200,
        :headers => headers
      )
    end
  end # Mock
end
