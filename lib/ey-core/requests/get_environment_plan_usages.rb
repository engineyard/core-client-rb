class Ey::Core::Client
  class Real
    def get_environment_plan_usages(params={})
      account_id    = params["account_id"]
      billing_month = params.fetch("billing_month", Date.today.strftime("%Y-%m"))

      request(
        :path => "accounts/#{account_id}/environment-plan-usages/#{billing_month}"
      )
    end
  end # Real

  class Mock
    def get_environment_plan_usages(params={})
      account_id    = params["account_id"]
      billing_month = params.fetch("billing_month", Date.today.strftime("%Y-%m"))

      response(
        :body   => { "environment_plan_usages" => self.find(:environment_plan_usages, account_id)[billing_month] || [] },
        :status => 200,
      )
    end
  end # Mock
end # Ey::Core::Client
