class Ey::Core::Client
  class Real
    def get_untracked_servers(params={})
      request(
        :params => params,
        :query  => Ey::Core.paging_parameters(params),
        :path   => "/untracked-servers",
        :url    => params.delete("url"),
      )
    end
  end # Real
  class Mock
    def get_untracked_servers(params={})
      extract_url_params!(params)

      headers, servers_page = search_and_page(params, :untracked_servers, search_keys: %w[provider provisioned_id provisioner_id location])

      response(
        :body    => {"untracked_servers" => servers_page},
        :headers => headers
      )
    end
  end # Mock
end
