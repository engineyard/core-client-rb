class Ey::Core::Client
  class Real
    def get_membership(params={})
      id  = params["id"]
      url = params["url"]

      request(
        :path => "memberships/#{id}",
        :url  => url,
      )
    end
  end # Real

  class Mock
    def get_membership(params={})
      response(
        :body => {"membership" => self.find(:memberships, resource_identity(params))},
      )
    end
  end # Mock
end # Ey::Core::Client
