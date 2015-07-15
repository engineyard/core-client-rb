class Ey::Core::Client
  class Real
    def get_accounts(params={})
      query = Ey::Core.paging_parameters(params)
      url   = params.delete("url")

      request(
        :params => params,
        :path   => "/accounts",
        :query  => query,
        :url    => url,
      )
    end
  end # Real
  class Mock
    def get_accounts(params={})
      extract_url_params!(params)

      user_id = if user_url = params.delete("user")
                  user_url.split('/').last
                end

      resources = if user_id
                    find(:users, user_id)
                    self.data[:accounts].select{|k,v| v[:account_users] && v[:account_users].include?(user_id)}
                  else
                    self.data[:accounts]
                  end

      #No need for mock to try and replicate the behavior of active_in_month, but does need to allow it and not get in the way
      params.delete("active_in_month")

      headers, accounts_page = search_and_page(params, :accounts, search_keys: %w[name id legacy_id], resources: resources)

      response(
        :body    => {"accounts" => accounts_page},
        :status  => 200,
        :headers => headers
      )
    end
  end # Mock
end
