class Ey::Core::Client
  class Real
    def signup(user, account, features = nil)
      params = {
        "user" => user,
        "account" => account,
      }
      params["features"] = features if features

      request(
        :method => :post,
        :path   => "/signups",
        :params => params,
      )
    end
  end # Real

  class Mock
    def signup(user, account, features = nil)
      if self.authentication != :hmac
        response(status: 403)
      end

      user_id = self.uuid

      user = user.dup
      user["token"] = SecureRandom.hex(20)

      user.merge!({
        "id"          => user_id,
        "accounts"    => url_for("/users/#{user_id}/accounts"),
        "memberships" => url_for("/users/#{user_id}/memberships"),
        "keypairs"    => url_for("/users/#{user_id}/keypairs"),
      })

      self.data[:users][user_id] = user

      account_id = self.uuid
      account = mock_account_setup(account_id, account.dup)

      self.data[:accounts][account_id] = account.merge(:account_users => [user_id], :account_owners => [user_id])

      features.each do |resource_id|
        feature = self.data[:features][resource_id]

        account_url = url_for("/accounts/#{account_id}")
        feature["account"] = account_url
      end

      response(
        :body => {
          "signup" => {
            "user_id"    => user_id,
            "account_id" => account_id,
          },
        },
        :status  => 201,
      )
    end
  end # Mock
end # Ey::Core::Client
