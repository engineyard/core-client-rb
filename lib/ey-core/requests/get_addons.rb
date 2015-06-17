class Ey::Core::Client
  class Real
    def get_addons(params={})
      url   = params.delete("url") or raise "URL needed"
      request(
        :params => params,
        :url    => url,
      )
    end
  end # Real

  class Mock
    def get_addons(params={})
      extract_url_params!(params)

      headers, addons_page = search_and_page(params, :addons, search_keys: %w[account id name])

      response(
        :body    => {"addons" => addons_page},
        :headers => headers
      )
    end
  end # Mock
end
