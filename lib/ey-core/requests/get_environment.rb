class Ey::Core::Client
  class Real
    def get_environment(params={})
      id  = params["id"]
      url = params["url"]

      request(
        :path => "environments/#{id}",
        :url  => url,
      )
    end
  end # Real

  class Mock
    def get_environment(params={})
      response(
        :body => {"environment" => self.find(:environments, resource_identity(params))},
      )
    end
  end # Mock
end # Ey::Core::Client
