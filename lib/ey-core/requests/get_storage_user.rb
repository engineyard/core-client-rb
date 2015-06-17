class Ey::Core::Client
  class Real
    def get_storage_user(params={})
      id  = params["id"]
      url = params["url"]

      request(
        :path => "/storage-users/#{id}",
        :url  => url,
      )
    end
  end # Real

  class Mock
    def get_storage_user(params={})
      response(
        :body => {"storage_user" => self.find(:storage_users, resource_identity(params))},
      )
    end
  end # Mock
end # Ey::Core::Client
