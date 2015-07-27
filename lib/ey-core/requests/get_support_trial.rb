class Ey::Core::Client
  class Real
    def get_support_trial(params={})
      url = params["url"]
      request(
        :url => url,
      )
    end
  end # Real

  class Mock
    def get_support_trial(params={})
      account_id = resource_identity(params)

      find(:accounts, account_id)
      support_trial = data[:support_trials][account_id]
      unless support_trial
        response(status: 404)
      end

      resource = support_trial.merge(
        "account"    => url_for("/accounts/#{account_id}")
      )

      response(
        :body   => {"support_trial" => resource},
        :status => 200,
      )
    end

    def self.support_trial_elibigle(client, account_id)
      account_url = client.url_for("/accounts/#{account_id}")
      client.data[:accounts][account_id]["support_trial"] = "#{account_url}/support_trial"
      client.data[:support_trials][account_id] ||= {
        "id"         => Cistern::Mock.random_numbers(4),
        "started_at" => nil,
        "expires_at" => nil,
      }
    end

    def self.support_trial_active(client, account_id, started_at = nil, expires_at = nil)
      support_trial_elibigle(client, account_id)
      started_at ||= Time.now
      expires_at ||= started_at + 60 * 60 * 24 * 30 #30 days
      client.data[:support_trials][account_id].merge!(
        "started_at" => started_at,
        "expires_at" => expires_at,
      )
    end
  end
end
