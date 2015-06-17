class Ey::Core::Client
  class Real
    def create_slots(params={})
      url        = params.delete("url")
      cluster_id = params.delete("cluster")

      request(
        :method => :post,
        :path   => "/clusters/#{cluster_id}/slots",
        :url    => url,
        :body   => params,
      )
    end
  end # Real

  class Mock
    def create_slots(params={})
      extract_url_params!(params)

      cluster     = find(:clusters, params["cluster"])
      cluster_url = url_for("/clusters/#{cluster["id"]}")

      slots = params["slots"]

      if slots["names"] && slots["quantity"]
        return response(
          status: 422,
          body: { errors: ["cannot accept both 'names' and 'quantity' params"] }
        )
      end

      quantity = slots.delete("quantity") || 1
      names = slots.delete("names") || quantity.times.map { self.uuid[0..6] }

      unless names.kind_of?(Array)
        return response(
          status: 422,
          body: { errors: ["slots[names] parameter must be an array"] }
        )
      end

      resources = names.map do |name|
        resource_id = self.uuid

        resource = params["slots"].dup
        resource["flavor"]  ||= "medium_64"
        resource["volumes"] ||= []
        resource["image"]   ||= nil

        resource.merge!(
          "id"            => resource_id,
          "name"          => name,
          "cluster"       => cluster_url,
          "components"    => url_for("/slots/#{resource_id}/components"),
          "configuration" => { "volumes" => [] },
          "disabled"      => false,
          "retired"       => false,
          "deleted_at"    => nil,
          "created_at"    => Time.now,
          "updated_at"    => Time.now,
        )

        if volume_config = cluster["configuration"] && cluster["configuration"]["slot"] && cluster["configuration"]["slot"]["volumes"]
          resource["configuration"]["volumes"] += volume_config
          resource["configuration"]["volumes"].uniq!
        end

        # find all the cluster_components for this cluster
        cluster_components = self.data[:cluster_components].select do |_,cluster_component|
          cluster_component["cluster"] == cluster_url
        end

        # bootstrap a slot_component for each cluster_component
        cluster_components.each do |_,cc|
          slot_component_id = self.uuid
          self.data[:slot_components][slot_component_id] = {
            "id"                => slot_component_id,
            "created_at"        => Time.now,
            "updated_at"        => Time.now,
            "deleted_at"        => nil,
            "configuration"     => deep_dup(cc["configuration"]),
            "name"              => cc["name"],
            "slot"              => url_for("/slots/#{resource_id}"),
            "cluster_component" => url_for("/cluster_components/#{cc['id']}"),
            "component"         => cc["component"],
            "_cluster"          => cluster_url,
            "_environment"      => cluster["environment"],
          }
        end

        self.data[:slots][resource_id] = resource
      end

      response(
        :body    => {"slots" => resources},
        :status  => 201,
      )
    end
  end # Mock
end # Ey::Core::Client
