class Ey::Core::Client
  class Real
    def get_load_balancer_services(params={})
      query            = Ey::Core.paging_parameters(params)
      load_balancer_id = params.delete("load_balancer_id")
      url              = params.delete("url")

      request(
        :params => params,
        :query  => query,
        :path   => "/load-balancers/#{load_balancer_id}/services",
        :url    => url,
      )
    end
  end # Real

  class Mock
    def get_load_balancer_services(params={})
      extract_url_params!(params)

      headers, page = search_and_page(params, :load_balancer_services, search_keys: %w[load_balancer provider_ssl_certificate protocol external_port internal_port])

      response(
        :body    => {"load_balancer_services" => page},
        :status  => 200,
        :headers => headers
      )
    end
  end # Mock
end
