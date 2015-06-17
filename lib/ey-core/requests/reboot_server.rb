class Ey::Core::Client
  class Real
    def reboot_server(params={})
      id  = params["id"]
      url = params["url"]

      request(
        :method => :post,
        :path   => "servers/#{id}/reboot",
        :url    => url,
      )
    end
  end # Real

  class Mock
    def reboot_server(params={})
      request_id  = self.uuid
      identity = resource_identity(params)

      find(:servers, identity)

      reboot_request = {
        "finished_at" => Time.now,
        "id"          => request_id,
        "started_at"  => Time.now,
        "successful"  => "true",
        "server"      => url_for("/servers/#{identity}"),
        "type"        => "reboot_server_request",
      }

      self.data[:requests][request_id] = reboot_request

      response(
        :body   => {"request" => reboot_request},
        :status => 201,
      )
    end
  end # Mock
end
