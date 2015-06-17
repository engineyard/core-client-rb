class Ey::Core::Client
  class Real
    def update_server(params={})
      request(
        :method => :put,
        :path   => "/servers/#{params.fetch("id")}",
        :body   => {"server" => params.fetch("server")},
      )
    end
  end

  class Mock
    def update_server(params={})
      server = find(:servers, params.fetch("id"))

      server_params = Cistern::Hash.slice(
        Cistern::Hash.stringify_keys(params["server"]),
        "provisioned_at", "deprovisioned_at", "disappeared_at"
      )

      server.merge!("state" => params["server"]["status"]) if params["server"]["status"]
      server.merge!(server_params.merge("updated_at" => Time.now))

      response(
        :body => { "server" => server },
      )
    end
  end
end
