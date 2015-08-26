class Ey::Core::Client
  class Real
    def get_addresses(params={})
      query = Ey::Core.paging_parameters(params)
      url   = params.delete("url")

      request(
        :params => params,
        :path   => "/addresses",
        :query  => query,
        :url    => url,
      )
    end
  end # Real
  class Mock
    def get_addresses(params={})
      extract_url_params!(params)

      headers, addresses_page = search_and_page(params, :addresses, search_keys: %w[provisioned_id ip_address server location provider])

      response(
        :body    => {"addresses" => addresses_page},
        :headers => headers
      )
    end
  end # Mock
end
