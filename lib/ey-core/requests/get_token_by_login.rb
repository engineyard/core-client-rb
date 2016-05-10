class Ey::Core::Client
  class Real
    def get_token_by_login(params={})
      url = params.delete("url")

      request(
        :authenticated => false,
        :body          => params,
        :method        => :post,
        :path          => "/tokens",
        :url           => url,
      )
    end
  end

  class Mock
    def get_token_by_login(params={})
      user = self.data[:users].values.detect { |u| u["username"] == params[:username] && u["password"] == params[:password] }

      if user
        response(
          :status => 200,
          :body   => {"api_token" => user["token"]},
        )
      else
        response(status: 401)
      end
    end
  end
end
