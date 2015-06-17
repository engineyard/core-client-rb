class Ey::Core::Client
  class Real
    def create_cluster_component(params={})
      cluster_id   = params["cluster"]
      component_id = params["component"]
      url          = params.delete("url")

      request(
        :method => :post,
        :path   => "/clusters/#{cluster_id}/components/#{component_id}",
        :url    => url,
        :body   => params,
      )
    end
  end # Real

  class Mock
    def create_cluster_component(params={})
      url_params = params["url"] && path_params(params.delete("url"))

      cluster_id = url_params && url_params["clusters"]
      cluster_id ||= params.delete("cluster")
      find(:clusters, cluster_id)

      component_id = url_params && url_params["components"]
      component_id ||= params.delete("component")
      find(:components, component_id)

      resource_id = self.uuid

      resource = params["cluster_component"]

      configuration = resource["configuration"] = normalize_hash(resource["configuration"] || {})

      if application_id = configuration["application"]
        find(:applications, application_id)
        resource.merge!("application" => url_for("/applications/#{application_id}"))
      end

      resource.merge!(
        "id"         => resource_id,
        "component"  => url_for("/components/#{component_id}"),
        "cluster"    => url_for("/clusters/#{cluster_id}"),
        "connectors" => url_for("/cluster-components/#{resource_id}/connectors"),
        "tasks"      => url_for("/cluster-components/#{resource_id}/tasks"),
        "keypairs"   => url_for("/cluster-components/#{resource_id}/keypairs"),
      )

      self.data[:cluster_components][resource_id] = resource

      response(
        :body    => {"cluster_component" => resource},
        :status  => 201,
      )
    end
  end # Mock
end # Ey::Core::Client
