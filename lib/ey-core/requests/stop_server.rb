class Ey::Core::Client
  class Real
    def stop_server(params={})
      id  = params["id"]
      url = params["url"]

      request(
        :method => :put,
        :path   => "servers/#{id}/stop",
        :url    => url,
      )
    end
  end # Real

  class Mock
    def stop_server(params={})
      request_id  = self.uuid
      identity = resource_identity(params)

      find(:servers, identity)

      stop_request = {
        "finished_at" => Time.now,
        "id"          => request_id,
        "started_at"  => Time.now,
        "successful"  => "true",
        "server"      => url_for("/servers/#{identity}"),
        "type"        => "stop_server_request",
      }

      self.data[:requests][request_id] = stop_request

      response(
        :body   => {"request" => stop_request},
        :status => 201,
      )
    end
  end # Mock
end
