class Ey::Core::Client
  class Real
    def update_connector(params={})
      request(
        :method => :put,
        :path   => "/connectors/#{params["id"]}",
        :body   => params,
      )
    end
  end # Real

  class Mock
    def update_connector(params={})
      identity = resource_identity(params)
      connector  = find(:connectors, identity)

      update_params = Cistern::Hash.slice(params["connector"], "configuration")

      # core api doesn't actually do this yet
      if config = update_params.delete("configuration")
        update_params["configuration"] = normalize_hash(config)
      end

      connector.merge!(update_params)

      response(
        :body => { "connector" => connector },
        :status => 200
      )
    end
  end # Mock
end # Ey::Core::Client
