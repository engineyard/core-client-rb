class Ey::Core::Client
  class Real
    def get_component_action(params={})
      id  = params["id"]
      url = params["url"]

      request(
        :path => "/component_actions/#{id}",
        :url  => url,
      )
    end
  end # Real

  class Mock
    def get_component_action(params={})
      response(
        :body => {"component_action" => self.find(:component_actions, resource_identity(params))},
      )
    end
  end # Mock
end # Ey::Core::Client
