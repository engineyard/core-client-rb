class Ey::Core::Client
  class Real
    def get_volumes(params={})
      query = Ey::Core.paging_parameters(params)
      url   = params["url"]

      request(
        :params => params,
        :query  => query,
        :path   => "/volumes",
        :url    => url,
      )
    end
  end # Real
  class Mock
    def get_volumes(params={})
      extract_url_params!(params)

      headers, volumes_page = search_and_page(params, :volumes, search_keys: %w[server name size iops mount device])

      response(
        :body    => {"volumes" => volumes_page},
        :status  => 200,
        :headers => headers
      )
    end
  end # Mock
end
