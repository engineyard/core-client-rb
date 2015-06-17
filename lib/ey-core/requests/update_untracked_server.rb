class Ey::Core::Client
  class Real
    def update_untracked_server(params={})
      request(
        :method => :put,
        :path   => "/untracked-servers/#{params.delete("id")}",
        :body   => params,
      )
    end
  end

  class Mock
    def update_untracked_server(params={})
      identity = resource_identity(params) || require_parameters(params["untracked_server"], "id")
      server  = find(:untracked_servers, identity)

      update_params = Cistern::Hash.slice(params["untracked_server"], "provisioner_id", "location", "state")

      response(
        :body => { "untracked_server" => server.merge!(update_params) },
      )
    end
  end
end
