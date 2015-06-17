class Ey::Core::Client
  class Real
    def get_storages(params={})
      query = Ey::Core.paging_parameters(params)
      url   = params.delete("url")

      request(
        :params => params,
        :query => query,
        :path  => "/storages",
        :url   => url,
      )
    end
  end # Real
  class Mock
    def get_storages(params={})
      extract_url_params!(params)

      headers, storages_page = search_and_page(params, :storages, search_keys: %w[name id provider])

      response(
        :body    => {"storages" => storages_page},
        :status  => 200,
        :headers => headers
      )
    end
  end # Mock
end
