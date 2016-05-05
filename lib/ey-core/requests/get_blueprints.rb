class Ey::Core::Client
  class Real
    def get_blueprints(params={})
      query = Ey::Core.paging_parameters(params)
      url   = params.delete("url")

      request(
        :path   => "/blueprints",
        :params => params,
        :query  => query,
        :url    => url,
      )
    end
  end

  class Mock
    def get_blueprints(params={})
      extract_url_params!(params)

      headers, blueprints_page = search_and_page(params, :blueprints, search_keys: %w[account environment environment_id name])

      response(
        :body    => {"blueprints" => blueprints_page},
        :status  => 200,
        :headers => headers,
      )
    end
  end
end
