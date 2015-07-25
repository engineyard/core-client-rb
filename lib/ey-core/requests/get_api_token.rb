class Ey::Core::Client
  class Real
    def get_api_token(username, password)
      request(
        :path   => "tokens",
        :method => :post,
        :body   => {email: username, password: password},
      )
    end
  end

  class Mock
    def get_api_token(username, password)
      response(
        :body => {"api_token" => self.api_token}
      )
    end
  end
end
