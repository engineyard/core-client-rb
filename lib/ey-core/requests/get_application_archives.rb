class Ey::Core::Client
  class Real
    def get_application_archives(params={})
      query          = Ey::Core.paging_parameters(params)
      url            = params.delete("url")
      application_id = params["application"]

      request(
        :params => params,
        :path   => "/applications/#{application_id}/archives",
        :query  => query,
        :url    => url
      )
    end
  end # Real

  class Mock
    def get_application_archives(params={})
      extract_url_params!(params)

      headers, archives_pages = search_and_page(params, :application_archives, search_keys: %w[application])

      response(
        :body    => {"application_archives" => archives_pages},
        :headers => headers
      )
    end
  end # Mock
end
