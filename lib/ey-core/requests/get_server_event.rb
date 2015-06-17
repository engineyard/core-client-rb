class Ey::Core::Client
  class Real
    def get_server_event(params={})
      url   = params.delete("url")
      id    = params.delete("id")

      request(
        :path => "/server-events/#{id}",
        :url  => url,
      )
    end
  end # Real
  class Mock
    def get_server_event(params={})
      response(
        :body => {"server_event" => self.find(:server_events, resource_identity(params))},
      )
    end
  end # Mock
end
