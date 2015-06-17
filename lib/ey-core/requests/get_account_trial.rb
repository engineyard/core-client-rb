class Ey::Core::Client
  class Real
    def get_account_trial(params={})
      url = params["url"]
      request(
        :url => url,
      )
    end
  end # Real

  class Mock
    def get_account_trial(params={})
      account_id = resource_identity(params)

      find(:accounts, account_id)

      resource = {
        "id"         => Cistern::Mock.random_numbers(4),
        "duration"   => 500,
        "used"       => 30,
        "created_at" => Time.now.to_s,
        "account"    => url_for("/accounts/#{account_id}")
      }

      response(
        :body   => {"account_trial" => resource},
        :status => 200,
      )
    end
  end
end
