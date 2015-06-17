class Ey::Core::Client
  class Real
    def get_application_deployments(params={})
      query = Ey::Core.paging_parameters(params)
      url   = params.delete("url")

      request(
        :params => params,
        :path   => "/application-deployments",
        :query  => query,
        :url    => url
      )
    end
  end # Real

  class Mock
    def get_application_deployments(params={})
      extract_url_params!(params)

      headers, application_deployments_page = search_and_page(params, :application_deployments, search_keys: %w[application cluster environment])

      response(
        :body    => {"application_deployments" => application_deployments_page},
        :headers => headers
      )
    end
  end # Mock
end
