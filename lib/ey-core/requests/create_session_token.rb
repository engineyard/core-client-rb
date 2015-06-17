class Ey::Core::Client
  class Real
    def create_session_token(params={})

      request(
        :method => :post,
        :path   => "session-tokens",
        :params => params,
      )
    end
  end # Real

  class Mock
    def create_session_token(params={})
      session_id = self.uuid

      response(
        :body    => {
          "session_token" => {
            "id"           => self.uuid,
            "on_behalf_of" => params["on_behalf_of"],
            "session_id"   => session_id,
            "expires_at"   => Time.now + (60 * 5),
            "redirect_url" => params["redirect_url"],
            "upgrade_url"  => "http://login.localdev.engineyard.com:9292/session-tokens/#{session_id}/upgrade",
          }
        },
        :status  => 201,
        :headers => {
          "Content-Type" => "application/json; charset=utf8"
        }
      )
    end
  end # Mock
end # Ey::Core::Client

