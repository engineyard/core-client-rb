class Ey::Core::Client
  class Real
    def destroy_user(params={})
      id  = params["id"]
      url = params.delete("url")

      request(
        :path   => "/users/#{id}",
        :url    => url,
        :method => :delete
      )
    end
  end

  class Mock
    def destroy_user(params={})
      url = params.delete("url")

      user_id = params["id"] || url && url.split('/').last

      self.data[:users][user_id]["deleted_at"] = Time.now

      response(
        :body   => nil,
        :status => 204,
      )
    end
  end
end
