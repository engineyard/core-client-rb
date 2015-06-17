class Ey::Core::Client
  class Real
    def update_cluster_component(params={})
      id = params.delete("id")
      request(
        :method => :put,
        :path   => "/cluster-components/#{id}",
        :body   => params,
      )
    end
  end

  class Mock
    def update_cluster_component(params={})
      cluster_component = find(:cluster_components, resource_identity(params))

      resource = params["cluster_component"]

      resource["configuration"] = normalize_hash(resource["configuration"] || {})

      cluster_component.merge!(resource)

      response(
        :body => {"cluster_component" => cluster_component},
        :status => 200
      )
    end
  end
end
