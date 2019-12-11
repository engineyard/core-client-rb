class Ey::Core::Client
  class Real
    def get_environments(params={})
      query = Ey::Core.paging_parameters(params)
      url   = params.delete("url")

      request(
        :params => params,
        :query  => query,
        :path   => "/environments",
        :url    => url,
      )
    end
  end # Real

  class Mock
    def get_environments(params={})
      extract_url_params!(params)

      headers, environments_page = search_and_page(params, :environments, search_keys: %w[id account name])

      response(
        :body    => {"environments" => environments_page},
        :status  => 200,
        :headers => headers
      )
    end
  end # Mock
end
