class Ey::Core::Client
  class Real
    def get_user(params={})
      id  = params["id"]
      url = params["url"]

      request(
        :path => "users/#{id}",
        :url  => url,
      )
    end
  end # Real

  class Mock
    def get_user(params={})
      response(
        :body => {"user" => self.find(:users, resource_identity(params))},
      )
    end
  end # Mock
end # Ey::Core::Client
