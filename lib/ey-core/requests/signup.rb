class Ey::Core::Client
  class Real
    def signup(_params)
      params = Cistern::Hash.stringify_keys(_params)

      request(
        :method => :post,
        :path   => "/signups",
        :body   => params,
      )
    end
  end # Real

  class Mock
    def signup(_params)
      params = Cistern::Hash.stringify_keys(_params)

      user_id = self.uuid

      user = params["user"].dup
      user.merge!({
        "id"          => user_id,
        "accounts"    => url_for("/users/#{user_id}/accounts"),
        "memberships" => url_for("/users/#{user_id}/memberships"),
        "keypairs"    => url_for("/users/#{user_id}/keypairs"),
        "token"       => SecureRandom.hex(20)
      })

      self.data[:users][user_id] = user

      account_id = self.uuid

      account = mock_account_setup(account_id, params["account"].dup)

      self.data[:accounts][account_id] = account.merge(:account_users => [user_id], :account_owners => [user_id])

      (params["features"] || []).each do |resource_id|
        feature = self.data[:features][resource_id]

        account_url = url_for("/accounts/#{account_id}")
        feature["account"] = account_url
      end

      response(
        :body => {
          "signup" => {
            "user_id"     => user_id,
            "account_id"  => account_id,
            "upgrade_url" => "http://login.localdev.engineyard.com:9292/session-tokens/#{self.uuid}/upgrade",
          },
        },
        :status  => 201,
      )
    end
  end # Mock
end # Ey::Core::Client
