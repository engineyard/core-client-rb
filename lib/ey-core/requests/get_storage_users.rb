class Ey::Core::Client
  class Real
    def get_storage_users(params={})
      query = Ey::Core.paging_parameters(params)
      url   = params.delete("url")

      request(
        :params => params,
        :query => query,
        :path  => "/storage-users",
        :url   => url,
      )
    end
  end # Real
  class Mock
    def get_storage_users(params={})
      extract_url_params!(params)

      headers, storage_users_page = search_and_page(params, :storage_users, search_keys: %w[username storage])

      response(
        :body    => {"storage_users" => storage_users_page},
        :status  => 200,
        :headers => headers
      )
    end
  end # Mock
end
