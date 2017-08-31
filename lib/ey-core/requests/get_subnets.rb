class Ey::Core::Client
  class Real
    def get_subnets(options={})
      query = Ey::Core.paging_parameters(options)
      url   = options.delete("url")

      request(
        :params => options,
        :query  => query,
        :path   => "/subnets",
        :url    => url,
      )
    end
  end

  class Mock
    def get_subnets(options={})
      extract_url_params!(options)

      headers, subnets_page = search_and_page(options, :subnets, search_keys: %w[network])

      response(
        :body    => {"subnets" => subnets_page},
        :status  => 200,
        :headers => headers
      )
    end
  end
end
