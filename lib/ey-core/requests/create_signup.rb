class Ey::Core::Client
  class Real
    def create_signup(params={})
      request(
        :method => :post,
        :path   => "/signups",
        :params => params,
      )
    end
  end # Real

  class Mock
    def create_signup(params={})
      if self.authentication != :hmac
        response(status: 403)
      end

      user_id = self.uuid

      user = params["user"].dup
      user["token"] = SecureRandom.hex(20)

      user.merge!({
        "id"          => user_id,
        "accounts"    => url_for("/users/#{user_id}/accounts"),
        "memberships" => url_for("/users/#{user_id}/memberships"),
        "keypairs"    => url_for("/users/#{user_id}/keypairs"),
      })

      self.data[:users][user_id] = user

      account_id = self.uuid
      account = mock_account_setup(account_id, params["account"].dup)

      self.data[:accounts][account_id] = account.merge(:account_users => [user_id], :account_owners => [user_id])

      response(
        :body => {
          "signup" => {
            "user"    => url_for("users/#{user_id}"),
            "account" => url_for("accounts/#{account_id}"),
          },
        },
        :status  => 201,
      )
    end
  end # Mock
end # Ey::Core::Client
