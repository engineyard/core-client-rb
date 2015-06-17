class Ey::Core::Client
  class Real
    def get_ssl_certificates(params={})
      query = Ey::Core.paging_parameters(params)
      url = params.delete("url")

      request(
        :params => params,
        :query  => query,
        :path   => "/ssl_certificates",
        :url    => url,
      )
    end
  end # Real
  class Mock
    def get_ssl_certificates(params={})
      extract_url_params!(params)

      headers, ssl_certificates_page = search_and_page(params, :ssl_certificates, search_keys: %w[account name])

      response(
        :body    => {"ssl_certificates" => ssl_certificates_page},
        :status  => 200,
        :headers => headers
      )
    end
  end # Mock
end
