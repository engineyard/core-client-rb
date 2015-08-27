class Ey::Core::Client
  class Real
    def create_deis_cluster(params={})
      request(
        :method => :post,
        :path   => "/deis-clusters",
        :body   => params,
        :url    => params.delete("url"),
      )
    end
  end # Real

  class Mock
    def create_deis_cluster(params={})
      url = params.delete("url")

      account_id = resource_identity(params)
      account_id ||= params["account"] || url && path_params(url)["accounts"]

      find(:accounts, account_id)

      resource = params["deis_cluster"].dup
      resource_id = self.uuid

      resource.merge!({
        "id"      => resource_id,
        "account" => url_for("/accounts/#{account_id}"),
        "agents"  => url_for("/deis-clusters/#{resource_id}/agents"),
      })

      self.data[:deis_clusters][resource_id] = resource

      response(
        :body    => {"deis_cluster" => resource},
        :status  => 201,
      )
    end
  end # Mock
end # Ey::Core::Client
