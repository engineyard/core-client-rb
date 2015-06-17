class Ey::Core::Client
  class Real
    def get_load_balancer_nodes(params={})
      query                    = Ey::Core.paging_parameters(params)
      load_balancer_service_id = params.delete("load_balancer_service")
      url                      = params.delete("url")

      request(
        :params => params,
        :query  => query,
        :path   => "/load-balancer-service/#{load_balancer_service_id}/nodes",
        :url    => url,
      )
    end
  end # Real

  class Mock
    def get_load_balancer_nodes(params={})
      extract_url_params!(params)

      headers, load_balancers_nodes_page = search_and_page(params, :load_balancer_nodes, search_keys: %w[load_balancer_service name server])

      response(
        :body    => {"load_balancer_nodes" => load_balancer_servicess_page},
        :status  => 200,
        :headers => headers
      )
    end
  end # Mock
end
