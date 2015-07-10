class Ey::Core::Client
  class Real
    def get_account_referrals(params={})

    end
  end

  class Mock
    def get_account_referrals(params={})
      extract_url_params!(params)

      headers, account_referrals_page = search_and_page(params, :account_referrals, search_keys: %w[referrer_account_id])

      response(
        :body    => {"account_referrals" => account_referrals_page},
        :status  => 200,
        :headers => headers
      )
    end
  end
end
