class Ey::Core::Client
  class Real
    def get_users(params={})
      query = Ey::Core.paging_parameters(params)
      url   = params.delete("url")

      request(
        :params => params,
        :path   => "/users",
        :query  => query,
        :url    => url,
      )
    end
  end # Real
  class Mock
    def get_users(params={})
      resources = if url = params.delete("url")
                    if account_id = path_params(url)["accounts"]
                      account = self.find(:accounts, account_id)

                      if url.index("/owners")
                        account[:account_owners].inject({}){|r,id| r.merge(id => self.data[:users][id])}
                      elsif url.index("/users")
                        account[:account_users].inject({}){|r,id| r.merge(id => self.data[:users][id])}
                      else
                        raise "Mock doesn't know how to handle url: #{url}"
                      end
                    else []
                    end
                  else
                    self.data[:users]
                  end

      headers, users_page = search_and_page(params, :users, search_keys: %w[name email first_name last_name], resources: resources)

      response(
        :body    => {"users" => users_page},
        :headers => headers
      )
    end
  end # Mock
end
