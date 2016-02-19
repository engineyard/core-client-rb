class Ey::Core::Client
  class Real
    def get_tokens(params={})
      query = Ey::Core.paging_parameters(params)
      url   = params.delete("url")

      request(
        :params => params,
        :query  => query,
        :path   => "/tokens",
        :url    => url,
      )
    end
  end

  class Mock
    def get_tokens(params={})
      extract_url_params!(params)
      find(:users, resource_identity(params["user"]))

      params["on_behalf_of"] = params.delete("user")

      headers, tokens_page = search_and_page(params, :tokens, search_keys: %w(on_behalf_of))

      response(
        :body    => {"tokens" => tokens_page},
        :status  => 200,
        :headers => headers,
      )
    end
  end
end
