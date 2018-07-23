class Ey::Core::Client
  class Real
    def get_deployments(params={})
      query = Ey::Core.paging_parameters(params)
      url   = params.delete("url")

      request(
        :params => params,
        :path   => "/deployments",
        :query  => query,
        :url    => url,
      )
    end
  end

  class Mock
    def get_deployments(params={})
      extract_url_params!(params)

      headers, deployments_page = search_and_page(params, :deployments, search_keys: %w(account environment application))

      response(
        :body    => {"deployments" => deployments_page},
        :status  => 200,
        :headers => headers
      )
    end
  end
end
