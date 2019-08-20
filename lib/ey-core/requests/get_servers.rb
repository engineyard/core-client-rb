class Ey::Core::Client
  class Real
    def get_servers(params={})
      params['per_page'] = ENV['CORE_SERVERS_PER_PAGE'] || 100
      request(
        :params => params,
        :query  => Ey::Core.paging_parameters(params),
        :path   => "/servers",
        :url    => params.delete("url"),
      )
    end
  end # Real

  class Mock
    def get_servers(params={})
      extract_url_params!(params)

      headers, servers_page = search_and_page(params, :servers, search_keys: %w[account environment provider state private_hostname public_hostname provisioned_id role])

      response(
        :body    => {"servers" => servers_page},
        :headers => headers
      )
    end
  end # Mock
end
