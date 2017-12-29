class Ey::Core::Client
  class Real
    def update_auto_scaling_policy(params = {})
      id = params.delete("id")

      request(
        :method => :put,
        :path   => "/auto_scaling_policies/#{id}",
        :body   => { "auto_scaling_policy" => params.fetch("auto_scaling_policy") },
      )
    end
  end

  class Mock
    def update_auto_scaling_policy(params = {})
      resource_id = params.delete("id")
      resource = find(:auto_scaling_policies, resource_id)
        .merge(params["auto_scaling_policy"])
        .merge("updated_at" => Time.now)
      resource.merge!(params)

      request = {
        "id"           => self.uuid,
        "type"         => "update_auto_scaling_policy",
        "successful"   => true,
        "created_at"   => now - 5,
        "updated_at"   => now,
        "started_at"   => now - 3,
        "finished_at"  => now,
        "message"      => nil,
        "read_channel" => nil,
        "resource"     => [:auto_scaling_policies, resource_id, resource],
        "resource_url" => url_for("/auto_scaling_policies/#{resource_id}")
      }

      self.data[:requests][request["id"]] = request

      response(
        body:   { "request" => request },
        status: 200
      )
    end
  end
end
