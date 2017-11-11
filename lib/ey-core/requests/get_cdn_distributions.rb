class Ey::Core::Client
  class Real
    def get_cdn_distributions(params={})
      query = Ey::Core.paging_parameters(params)
      url = params.delete("url")

      request(
        :params => params,
        :query  => query,
        :path   => "/cdn-distributions",
        :url    => url,
      )
    end
  end

  class Mock
    def get_cdn_distributions(params={})
      extract_url_params!(params)

      headers, cdn_distributions_page = search_and_page(params, :cdn_distributions, search_keys: %w[application environment])

      response(
        :body    => {"cdn_distributions" => cdn_distributions_page},
        :status  => 200,
        :headers => headers
      )
    end
  end # Mock
end
