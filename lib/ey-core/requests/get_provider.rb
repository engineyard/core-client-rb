class Ey::Core::Client
  class Real
    def get_provider(params={})
      id  = params["id"]
      url = params["url"]

      request(
        :path => "providers/#{id}",
        :url  => url,
      )
    end
  end # Real

  class Mock
    def get_provider(params={})
      response(
        :body => {"provider" => self.find(:providers, resource_identity(params))},
      )
    end
  end # Mock
end # Ey::Core::Client
