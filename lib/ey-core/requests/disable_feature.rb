class Ey::Core::Client
  class Real
    def disable_feature(params={})
      feature_id = params["feature"]["id"]
      account_id = params["account"]

      request(
        :method => :delete,
        :path   => "accounts/#{account_id}/features/#{feature_id}",
      )
    end
  end # Real

  class Mock
    def disable_feature(params={})
      account_id = params["account"]
      feature_id = params["feature"]["id"]

      account = find(:accounts, account_id)
      feature = find(:features, feature_id)

      feature["account"] = nil

      response(
        :body   => nil,
        :status => 200
      )
    end
  end # Mock
end
