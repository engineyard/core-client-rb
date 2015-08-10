class Ey::Core::Client
  class Real
    def reset_password(_params)
      params = Cistern::Hash.stringify_keys(_params)

      request(
        :method => :put,
        :path   => "/password-resets/#{params["reset_token"]}",
        :body   => {
          :password_reset => {
            :password => params["password"]
          }
        },
      )
    end
  end # Real

  class Mock
    def reset_password(*)
      response(
        :body => {
          "password_reset" => {
            "accepted" => true
          },
        },
        :status  => 201,
      )
    end
  end # Mock
end # Ey::Core::Client

