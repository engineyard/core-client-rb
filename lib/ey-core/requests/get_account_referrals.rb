class Ey::Core::Client
  class Real
    def get_account_referrals(params={})
      request(
        :url => params.delete("url"),
        :path => "/account-referrals",
      )
    end
  end

  class Mock
    def get_account_referrals(params={})
      extract_url_params!(params)

      if params["account"]
        params["referrer"] = params.delete("account")
      end

      headers, account_referrals_page = search_and_page(params, :account_referrals, search_keys: %w[referrer])

      response(
        :body    => {"account_referrals" => account_referrals_page},
        :status  => 200,
        :headers => headers
      )
    end
  end
end
