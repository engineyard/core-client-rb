class Ey::Core::Client
  class Real
    def get_alerts(params={})

      puts "DEBUG - #{self.class}#get_alerts - Hey! I'm running"

      url   = params.delete("url")
      query = Ey::Core.paging_parameters(params)

      request(
        :params => params,
        :query  => query,
        :path   => "/alerts",
        :url    => url,
      )
    end
  end # Real

  class Mock
    def get_alerts(params={})
      extract_url_params!(params)

      if params["server"] && params["database_server"]
        return response(status: 422, body: "Cannot search for both server & database_server")
      end

      if database_server_id = resource_identity(params.delete("database_server"))
        params["resource"] = url_for("/database-servers/#{database_server_id}")
      end

      if server_id = resource_identity(params.delete("server"))
        params["resource"] = url_for("/servers/#{server_id}")
      end

      if agent_id = resource_identity(params.delete("agent"))
        params["resource"] = url_for("/agents/#{agent_id}")
      end

      headers, alerts_page = search_and_page(params, :alerts, search_keys: %w[resource external_id name severity agent finished_at started_at], deleted_key: "finished_at")

      response(
        :body    => {"alerts" => alerts_page},
        :headers => headers
      )
    end
  end # Mock
end
