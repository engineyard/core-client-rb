class Ey::Core::Client
  class Real
    def get_server_events(params={})
      query = Ey::Core.paging_parameters(params)
      url   = params.delete("url")

      request(
        :params => params,
        :query  => query,
        :path   => "/server-events",
        :url    => url,
      )
    end
  end # Real
  class Mock
    def get_server_events(params={})
      extract_url_params!(params)

      headers, server_events_page = search_and_page(params, :server_events, search_keys: %w[slot server environment])

      response(
        :body    => {"server_events" => server_events_page},
        :status  => 200,
        :headers => headers
      )
    end
  end # Mock
end
