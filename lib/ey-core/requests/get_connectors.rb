class Ey::Core::Client
  class Real
    def get_connectors(params={})
      query = Ey::Core.paging_parameters(params)
      url   = params["url"]

      request(
        :params => params,
        :query => query,
        :path  => "/connectors",
        :url   => url,
      )
    end
  end # Real
  class Mock
    def get_connectors(params={})
      extract_url_params!(params)

      resources = if cluster_component = params.delete("cluster_component")
                    self.data[:connectors].select { |_, v| v["source"].match(cluster_component) || v["destination"].match(cluster_component) }
                  else self.data[:connectors]
                  end

      if environment_id = resource_identity(params.delete("environment"))
        params["environment"] = url_for("/environments/#{environment_id}")
      end

      headers, connectors_page = search_and_page(params, :connectors, resources: resources, search_keys: %w[environment])

      response(
        :body    => {"connectors" => connectors_page},
        :status  => 200,
        :headers => headers
      )
    end
  end # Mock
end
