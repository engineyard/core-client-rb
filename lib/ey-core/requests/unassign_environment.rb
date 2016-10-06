class Ey::Core::Client
  class Real
    def unassign_environment(params={})
      id  = params["id"]
      url = params["url"]

      request(
        :method => :put,
        :url    => url,
        :path   => "/environments/#{id}/unassign",
      )
    end
  end # Real

  class Mock
    def unassign_environment(params={})
      request_id = self.uuid
      url         = params.delete("url")

      environment_id = params["id"] || url && url.split('/').last

      environment = self.data[:environments][environment_id]
      environment[:assignee] = nil

      response(
        :body   => {"environment" => environment},
        :status => 200,
      )
    end
  end # Mock
end # Ey::Core::Client
