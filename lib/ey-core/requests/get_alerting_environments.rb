class Ey::Core::Client
  class Real
    def get_alerting_environments(params={})
      query = Ey::Core.paging_parameters(params)
      url   = params.delete("url")

      request(
        :params => params,
        :query  => query,
        :path   => "/environments/alerting",
        :url    => url,
      )
    end
  end # Real

  class Mock
    def get_alerting_environments(params={})
      extract_url_params!(params)

      resources = self.data[:legacy_alerts].map do |id, alert|
        server_id = resource_identity(alert["server"])
        self.data[:servers][server_id]
      end.compact.map do |server|
        environment_id = resource_identity(server["environment"])
        self.data[:environments][environment_id]
      end.compact.uniq.inject({}) {|hash, env| hash[env["id"]] = env; hash}

      headers, environments_page = search_and_page(params, :environments, search_keys: %w[account project name], resources: resources)

      response(
        :body    => {"environments" => environments_page},
        :status  => 200,
        :headers => headers
      )
    end
  end # Mock
end
