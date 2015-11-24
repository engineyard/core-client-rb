class Ey::Core::Client
  class Real
    def get_logical_databases(params={})
      query = Ey::Core.paging_parameters(params)
      url = params.delete("url")

      request(
        :params => params,
        :query  => query,
        :path   => "/logical-databases",
        :url    => url,
      )
    end
  end

  class Mock
    def get_logical_databases(_params={})
      params = Cistern::Hash.stringify_keys(_params)

      extract_url_params!(params)

      params["service"] = params.delete("database_service") if params["database_service"]
      if environment_id = resource_identity(params.delete("environment") || params.delete("environment_id"))
        params["service"] = url_for("/database-services/#{find(:environments, environment_id)["database_service"]}")
      end

      headers, logical_databases_page = search_and_page(params, :logical_databases, search_keys: %w[name username service ])

      response(
        :body    => {"logical_databases" => logical_databases_page},
        :status  => 200,
        :headers => headers
      )
    end
  end
end
