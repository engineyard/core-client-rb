class Ey::Core::Client
  class Real
    def create_user(params={})
      request(
        :method => :post,
        :path   => "/users",
        :body   => params,
      )
    end
  end # Real

  class Mock
    def create_user(params={})
      if self.data[:users].map{ |_, user| user["email"] }.include?(params["user"]["email"])
        response(
          :status => 422,
          :body => {
            :errors => ["Email has already been taken"]
          }
        )
      end

      resource_id   = self.uuid
      token_id      = self.uuid
      token_auth_id = self.uuid

      resource = params["user"].dup

      resource.merge!({
        "id"            => resource_id,
        "accounts"      => url_for("/users/#{resource_id}/accounts"),
        "memberships"   => url_for("/users/#{resource_id}/memberships"),
        "keypairs"      => url_for("/users/#{resource_id}/keypairs"),
        "tokens"        => url_for("/users/#{resource_id}/tokens"),
        "environments"  => url_for("/accounts/#{resource_id}/environments"),
        "applications"  => url_for("/accounts/#{resource_id}/applications"),
        "api_token"     => SecureRandom.hex(16),
      })

      self.data[:tokens][token_id] = {
        "id"           => token_id,
        "auth_id"      => token_auth_id,
        "on_behalf_of" => url_for("/users/#{resource_id}"),
      }

      self.data[:users][resource_id] = resource

      response(
        :body    => {"user" => resource},
        :status  => 201,
      )
    end
  end # Mock
end # Ey::Core::Client
