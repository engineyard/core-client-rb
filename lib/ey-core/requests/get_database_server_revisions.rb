class Ey::Core::Client
  class Real
    def get_database_server_revisions(params={})
      database_server = params.delete("database_server")

      request(
        :body  => params,
        :query => Ey::Core.paging_parameters(params),
        :path  => "/database-servers/#{database_server}/revisions",
        :url   => params.delete("url"),
      )
    end
  end

  class Mock
    def get_database_server_revisions(params={})
      extract_url_params!(params)

      headers, page = search_and_page(params, :database_server_revisions, search_keys: %w[database_server])

      response(
        :body    => {"database_server_revisions" => page},
        :headers => headers,
      )
    end
  end
end
