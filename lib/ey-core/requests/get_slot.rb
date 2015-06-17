class Ey::Core::Client
  class Real
    def get_slot(params={})
      id  = params["id"]
      url = params["url"]

      request(
        :path => "slots/#{id}",
        :url  => url,
      )
    end
  end # Real

  class Mock
    def get_slot(params={})
      response(
        :body => {"slot" => self.find(:slots, resource_identity(params))},
      )
    end
  end # Mock
end # Ey::Core::Client
