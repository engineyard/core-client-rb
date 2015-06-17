class Ey::Core::Client
  class Real
    def get_providers(params={})
      query = Ey::Core.paging_parameters(params)
      url   = params.delete("url")

      request(
        :params => params,
        :query  => query,
        :path   => "/providers",
        :url    => url,
      )
    end
  end # Real
  class Mock
    def get_providers(params={})
      extract_url_params!(params)

      headers, providers_page = search_and_page(params, :providers, search_keys: %w[name account provisioned_id type])

      response(
        :body    => {"providers" => providers_page},
        :status  => 200,
        :headers => headers
      )
    end
  end # Mock
end
