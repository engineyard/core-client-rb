class Ey::Core::Client
  class Real
    def get_current_user(params={})
      request(
        :path => "/users/current",
      )
    end
  end # Real

  class Mock
    def get_current_user(params={})
      if current_user
        get_user("id" => current_user["id"])
      else
        response(status: 404)
      end
    end
  end # Mock
end # Ey::Core::Client
