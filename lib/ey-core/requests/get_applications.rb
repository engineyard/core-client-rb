class Ey::Core::Client
  class Real
    def get_applications(params={})
      query = Ey::Core.paging_parameters(params)
      url   = params.delete("url")

      request(
        :params => params,
        :path   => "/applications",
        :query  => query,
        :url    => url
      )
    end
  end # Real

  class Mock
    def get_applications(params={})
      extract_url_params!(params)

      headers, applications_page = search_and_page(params, :applications, search_keys: %w[id type repository account name environment])

      response(
        :body    => {"applications" => applications_page},
        :headers => headers
      )
    end
  end # Mock
end
