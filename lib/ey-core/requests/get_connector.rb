class Ey::Core::Client
  class Real
    def get_connector(params={})
      id  = params["id"]
      url = params["url"]

      request(
        :path => "connectors/#{id}",
        :url  => url,
      )
    end
  end # Real

  class Mock
    def get_connector(params={})
      response(
        :body => {"connector" => self.find(:connectors, resource_identity(params))},
      )
    end
  end # Mock
end # Ey::Core::Client
