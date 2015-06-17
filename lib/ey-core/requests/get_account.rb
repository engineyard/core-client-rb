class Ey::Core::Client
  class Real
    def get_account(params={})
      id  = params["id"]
      url = params["url"]

      request(
        :path => "accounts/#{id}",
        :url  => url,
      )
    end
  end # Real

  class Mock
    def get_account(params={})
      identity = resource_identity(params)

      account = self.find(:accounts, identity)
      resource = account.dup

      resource.delete(:users)
      resource.delete(:owners)

      response(
        :body => {"account" => resource},
      )
    end
  end # Mock
end # Ey::Core::Client
