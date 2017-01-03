class Ey::Core::Client
  class Real
    def start_server(params={})
      id  = params["id"]
      url = params["url"]

      request(
        :method => :put,
        :path   => "servers/#{id}/start",
        :url    => url,
      )
    end
  end # Real

  class Mock
    def start_server(params={})
      request_id  = self.uuid
      identity = resource_identity(params)

      find(:servers, identity)

      start_request = {
        "finished_at" => Time.now,
        "id"          => request_id,
        "started_at"  => Time.now,
        "successful"  => "true",
        "server"      => url_for("/servers/#{identity}"),
        "type"        => "start_server_request",
      }

      self.data[:requests][request_id] = start_request

      response(
        :body   => {"request" => start_request},
        :status => 201,
      )
    end
  end # Mock
end
