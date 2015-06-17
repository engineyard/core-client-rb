class Ey::Core::Client
  class Real
    def get_application(params={})
      id  = params["id"]
      url = params["url"]

      request(
        :path => "applications/#{id}",
        :url  => url
      )
    end
  end # Real

  class Mock
    def get_application(params={})
      response(
        :body => {"application" => self.find(:applications, resource_identity(params))},
      )
    end
  end # Mock
end # Ey::Core::Client
