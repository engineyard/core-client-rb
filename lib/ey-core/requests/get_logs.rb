class Ey::Core::Client
  class Real
    def get_logs(params={})
      query = Ey::Core.paging_parameters(params)
      url   = params.delete("url")

      request(
        :params => params,
        :query  => query,
        :path   => "/logs",
        :url    => url
      )
    end
  end

  class Mock
    def get_logs(params={})
      extract_url_params!(params)

      if cluster = params.delete("cluster")
        params["_cluster"] = cluster
      end

      if cluster_update = params.delete("cluster_update")
        params["_cluster_update"] = cluster_update
      end

      headers, logs_page = search_and_page(params, :logs, search_keys: %w[component_action _cluster _cluster_update])

      response(
        :body    => {"logs" => logs_page},
        :status  => 200,
        :headers => headers
      )
    end
  end
end
