class Ey::Core::Client
  class Real
    def get_slots(params={})
      query = Ey::Core.paging_parameters(params)
      url   = params.delete("url")

      request(
        :params => params,
        :query  => query,
        :path   => "/slots",
        :url    => url,
      )
    end
  end # Real
  class Mock
    def get_slots(params={})
      extract_url_params!(params)

      headers, slots_page = search_and_page(params, :slots, search_keys: %w[cluster name disabled])

      response(
        :body    => {"slots" => slots_page},
        :status  => 200,
        :headers => headers
      )
    end
  end # Mock
end
