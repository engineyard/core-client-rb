class Ey::Core::Client
  class Real
    def get_component(params={})
      id  = params["id"]
      url = params["url"]

      request(
        :path => "/components/#{id}",
        :url  => url,
      )
    end
  end # Real

  class Mock
    def get_component(params={})
      response(
        :body => {"component" => self.find(:components, resource_identity(params))},
      )
    end
  end # Mock
end # Ey::Core::Client
