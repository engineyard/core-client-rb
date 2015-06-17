class Ey::Core::Client
  class Real
    def get_volume(params={})
      id  = params["id"]
      url = params["url"]

      request(
        :path => "volumes/#{id}",
        :url  => url
      )
    end
  end # Real

  class Mock
    def get_volume(params={})
      response(
        :body => {"volume" => self.find(:volumes, resource_identity(params))},
      )
    end
  end # Mock
end # Ey::Core::Client
