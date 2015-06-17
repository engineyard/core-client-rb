class Ey::Core::Client
  class Real
    def update_slot_component(params={})
      id = params.delete("id")
      request(
        :method => :put,
        :path   => "/slot-components/#{id}",
        :body   => params,
      )
    end
  end

  class Mock
    def update_slot_component(params={})
      slot_component = find(:slot_components, resource_identity(params))

      resource = params["slot_component"]

      resource["configuration"] = normalize_hash(resource["configuration"] || {})

      slot_component.merge!(resource)

      response(
        :body => {"slot_component" => slot_component},
        :status => 200
      )
    end
  end
end
