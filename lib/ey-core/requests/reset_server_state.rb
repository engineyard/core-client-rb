class Ey::Core::Client
  class Real
    def reset_server_state(params={})
      id  = params.delete("id")
      url = params.delete("url")

      request(
        :method => :put,
        :path   => "servers/#{id}/reset_state",
        :body   => params,
        :url    => url,
      )
    end
  end # Real

  class Mock
    def reset_server_state(params={})
      id    = params["id"]
      state = params["state"]

      if server = self.data[:servers][id]
        server[:state] = state
        response(
          :body   => {"server" => server},
          :status => 200,
        )
      else
        response(status: 404)
      end
    end
  end # Mock
end
