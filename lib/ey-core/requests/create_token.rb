class Ey::Core::Client
  class Real
    def create_token(params={})

      request(
        :method => :post,
        :path   => "tokens",
        :params => params,
      )
    end
  end # Real

  class Mock
    def create_token(params={})
      response(
        :body    => {"token" => {"auth_id" => self.uuid}},
        :status  => 201,
        :headers => {
          "Content-Type" => "application/json; charset=utf8"
        }
      )
    end
  end # Mock
end # Ey::Core::Client
