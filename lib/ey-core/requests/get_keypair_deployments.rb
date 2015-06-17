class Ey::Core::Client
  class Real
    def get_keypair_deployments(params={})
      query = Ey::Core.paging_parameters(params)
      url   = params.delete("url")

      request(
        :params => params,
        :query  => query,
        :path   => "/keypair-deployments",
        :url    => url,
      )
    end
  end # Real

  class Mock
    def get_keypair_deployments(params={})
      extract_url_params!(params)

      headers, keypair_deployments_page = search_and_page(params, :keypair_deployments, search_keys: %w[keypair name fingerprint target])

      response(
        :body    => {"keypair_deployments" => keypair_deployments_page},
        :status  => 200,
        :headers => headers
      )
    end
  end # Mock
end
