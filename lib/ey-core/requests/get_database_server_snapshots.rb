class Ey::Core::Client
  class Real
    def get_database_server_snapshots(params={})
      database_server = params.delete("database_server")
      provider        = params.delete("provider")

      path = if database_server
               "/database-servers/#{database_server}/snapshots"
             elsif provider
               "/providers/#{provider}/database-server-snapshots"
             end

      request(
        :body  => params,
        :query => Ey::Core.paging_parameters(params),
        :path  => path,
        :url   => params.delete("url"),
      )
    end
  end

  class Mock
    def get_database_server_snapshots(params={})
      extract_url_params!(params)

      headers, database_server_snapshots_page = search_and_page(params, :database_server_snapshots, search_keys: %w[database_server database_service provider provisioned_id])

      response(
        :body    => {"database_server_snapshots" => database_server_snapshots_page},
        :headers => headers,
      )
    end
  end
end
