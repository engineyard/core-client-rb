class Ey::Core::Client
  class Real
    def create_password_reset(params)
      request(
        :method => :post,
        :path   => "/password-resets",
        :body   => {
          :password_reset => params
        }
      )
    end
  end # Real

  class Mock
    def create_password_reset(_params)
      params = Cistern::Hash.stringify_keys(_params)

      unless self.data[:users].map{ |_, user| user["email"] }.include?(params["email"])
        response(
          :body => {
            :errors => ["Could not find User with email \"#{params["email"]}\""]
          },
          :status => 404
        )
      end

      response(
        :body => {
          "password_reset" => {
            "sent" => true
          },
        },
        :status  => 201,
      )
    end
  end # Mock
end # Ey::Core::Client

