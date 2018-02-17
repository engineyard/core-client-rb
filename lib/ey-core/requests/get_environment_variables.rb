class Ey::Core::Client
  class Real
    def get_environment_variables(params={})
      query = Ey::Core.paging_parameters(params)
      url   = params.delete("url")

      request(
        :params => params,
        :path   => "/environment_variables",
        :query  => params,
        :url    => url,
      )
    end
  end

  class Mock
    def get_environment_variables(params={})
      extract_url_params!(params)

      headers, environment_variables_page = search_and_page(params, :environment_variables, search_keys: %w(environment application))

      response(
        :body    => {"environment_variables" => environment_variables_page},
        :status  => 200,
        :headers => headers
      )
    end
  end
end
