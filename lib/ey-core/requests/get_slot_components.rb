class Ey::Core::Client
  class Real
    def get_slot_components(params={})
      query = Ey::Core.paging_parameters(params)
      url   = params.delete("url")

      request(
        :params => params,
        :query  => query,
        :path   => "/slot-components",
        :url    => url,
      )
    end
  end # Real
  class Mock
    def get_slot_components(params={})
      extract_url_params!(params)

      if cluster_id = resource_identity(params.delete("cluster"))
        params["cluster"] = url_for("/clusters/#{cluster_id}")
      end

      if environment_id = resource_identity(params.delete("environment"))
        params["environment"] = url_for("/environments/#{environment_id}")
      end

      headers, slot_components_page = search_and_page(params, :slot_components, search_keys: %w[slot cluster environment])

      response(
        :body    => {"slot_components" => slot_components_page},
        :status  => 200,
        :headers => headers
      )
    end
  end # Mock
end
