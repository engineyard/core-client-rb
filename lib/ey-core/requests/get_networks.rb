class Ey::Core::Client
  class Real
    def get_networks(options={})
      query = Ey::Core.paging_parameters(options)
      url   = options.delete("url")

      request(
        :params => options,
        :query  => query,
        :path   => "/networks",
        :url    => url,
      )
    end
  end

  class Mock
    def get_networks(options={})
      extract_url_params!(options)

      headers, networks_page = search_and_page(options, :networks, search_keys: %w[provider])

      response(
        :body    => {"networks" => networks_page},
        :status  => 200,
        :headers => headers
      )
    end
  end
end
