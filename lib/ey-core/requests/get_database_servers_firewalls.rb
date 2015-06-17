class Ey::Core::Client
  class Real
    def get_database_servers_firewalls(params={})
      query = Ey::Core.paging_parameters(params)
      url = params.delete("url")
      id = params["database_server_id"]

      request(
        :params => params,
        :query  => query,
        :path   => "/database-servers/#{id}/firewalls",
        :url    => url,
      )
    end
  end

  class Mock
    def get_database_servers_firewalls(params={})
      extract_url_params!(params)

      headers, firewalls_page = search_and_page(params, :firewalls, search_keys: %w[cluster name])

      response(
        :body    => {"firewalls" => firewalls_page},
        :status  => 200,
        :headers => headers
      )
    end
  end
end
