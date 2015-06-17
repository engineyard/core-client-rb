class Ey::Core::Client
  class Real
    def get_slot_component(params={})
      id  = params["id"]
      url = params["url"]

      request(
        :path => "slot-components/#{id}",
        :url  => url,
      )
    end
  end # Real

  class Mock
    def get_slot_component(params={})
      response(
        :body => {"slot_component" => self.find(:slot_components, resource_identity(params))},
      )
    end
  end # Mock
end # Ey::Core::Client
