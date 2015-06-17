class Ey::Core::Client
  class Real
    def create_connector(params={})
      url = params.delete("url")

      request(
        :method => :post,
        :path   => "/connectors",
        :body   => params,
        :url    => url,
      )
    end
  end # Real

  class Mock
    def create_connector(params={})
      resource_id = self.uuid

      resource       = params["connector"].dup
      destination_id = resource.delete("destination")
      source_id      = resource.delete("source")

      resource["configuration"] = normalize_hash(resource["configuration"] || {})

      key, source = find([:cluster_components, :logical_databases], source_id)
      dest = find(:cluster_components, destination_id)

      environment_url = find(:clusters, dest["cluster"])["environment"] if dest.has_key?("cluster")
      environment_url = find(:clusters, source["cluster"])["environment"] unless environment_url

      resource.merge!(
        "source"       => url_for("/#{key}/#{source_id}"),
        "destination"  => url_for("/cluster-components/#{destination_id}"),
        "id"           => resource_id,
        "_environment" => environment_url,
      )

      self.data[:connectors][resource_id] = resource

      response(
        :body   => {"connector" => resource},
        :status => 201,
      )
    end
  end # Mock
end # Ey::Core::Client
