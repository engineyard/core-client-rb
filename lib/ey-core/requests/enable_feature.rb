class Ey::Core::Client
  class Real
    def enable_feature(params={})
      account_id = params["account"]
      feature_id = params["feature"]["id"]

      request(
        :method => :post,
        :path   => "accounts/#{account_id}/features/#{feature_id}"
      )
    end
  end # Real

  class Mock
    def enable_feature(params={})
      account_id  = params["account"]
      resource_id = params["feature"]["id"]

      account = self.data[:accounts][account_id]
      feature = self.data[:features][resource_id]

      account_url = url_for("/accounts/#{account_id}")
      feature["account"] = account_url

      response(
        :body   => {"feature" => {
                      "id" => feature[:id],
                      "name" => feature[:name],
                      "description" => feature[:description]}
                    },
        :status => 200
      )
    end
  end # Mock
end # Ey::Core::Client
