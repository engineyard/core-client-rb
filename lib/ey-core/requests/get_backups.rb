class Ey::Core::Client
  class Real
    def get_backups(params={})
      query = Ey::Core.paging_parameters(params)
      url   = params["url"]

      request(
        :query => query,
        :path  => "/backups",
        :url   => url,
      )
    end
  end # Real
  class Mock
    def get_backups(params={})
      extract_url_params!(params)

      headers, backups_page = search_and_page(params, :backups, search_keys: %w[cluster finished])

      response(
        :body    => {"backups" => backups_page},
        :status  => 200,
        :headers => headers
      )
    end
  end # Mock
end
