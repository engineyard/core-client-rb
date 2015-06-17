class Ey::Core::Client
  class Real
    def get_database_servers(params={})
      query = Ey::Core.paging_parameters(params)
      url = params.delete("url")

      request(
        :params => params,
        :query  => query,
        :path   => "/database-servers",
        :url    => url,
      )
    end
  end

  class Mock
    def get_database_servers(params={})
      extract_url_params!(params)
      extract_url_params!(params)

      headers, database_servers_page = search_and_page(params, :database_servers, search_keys: %w[provisioned_id provider database_service flavor location])

      response(
        :body    => {"database_servers" => database_servers_page},
        :status  => 200,
        :headers => headers
      )
    end
  end
end
