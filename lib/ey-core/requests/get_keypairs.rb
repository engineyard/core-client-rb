class Ey::Core::Client
  class Real
    def get_keypairs(params={})
      query = Ey::Core.paging_parameters(params)
      url   = params.delete("url")

      request(
        :params => params,
        :query  => query,
        :path   => "/keypairs",
        :url    => url,
      )
    end
  end  #  Real

  class Mock
    def get_keypairs(params={})
      extract_url_params!(params)

      if environment = params.delete("environment")
        deployments = get_keypair_deployments("target" => environment).body["keypair_deployments"]
        params["id"] = deployments.map {|d| resource_identity(d["keypair"]) }
      end

      headers, keypairs_page = search_and_page(params, :keypairs, search_keys: %w[application user name fingerprint id])

      response(
        :body    => {"keypairs" => keypairs_page},
        :status  => 200,
        :headers => headers
      )
    end
  end  #  Mock
end
