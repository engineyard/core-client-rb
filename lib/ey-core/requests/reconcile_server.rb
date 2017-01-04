class Ey::Core::Client
  class Real
    def reconcile_server(params={})
      id  = params["id"]
      url = params["url"]

      request(
        :method => :put,
        :path   => "servers/#{id}/reconcile",
        :url    => url,
      )
    end
  end # Real

  class Mock
    def reconcile_server(params={})
      request_id  = self.uuid
      identity = resource_identity(params)

      find(:servers, identity)

      reconcile_request = {
        "finished_at" => Time.now,
        "id"          => request_id,
        "started_at"  => Time.now,
        "successful"  => "true",
        "server"      => url_for("/servers/#{identity}"),
        "type"        => "reconcile_server_request",
      }

      self.data[:requests][request_id] = reconcile_request

      response(
        :body   => {"request" => reconcile_request},
        :status => 201,
      )
    end
  end # Mock
end
