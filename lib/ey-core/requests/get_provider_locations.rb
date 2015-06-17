class Ey::Core::Client
  class Real
    def get_provider_locations(params={})
      query       = Ey::Core.paging_parameters(params)
      url         = params.delete("url")

      request(
        :params => params,
        :query  => query,
        :url    => url,
      )
    end
  end # Real

  class Mock
    def get_provider_locations(params={})
      extract_url_params!(params)

      headers, provider_locations_page = search_and_page(params, :provider_locations, search_keys: %w[provider name location_id])

      response(
        :body    => {"provider_locations" => provider_locations_page},
        :status  => 200,
        :headers => headers
      )
    end
  end # Mock
end
