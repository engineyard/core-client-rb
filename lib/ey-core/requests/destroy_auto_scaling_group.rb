class Ey::Core::Client
  class Real
    def destroy_auto_scaling_group(params={})
      id  = params["id"]
      url = params["url"]

      request(
        :method => :delete,
        :url    => url,
        :path   => "/auto_scaling_groups/#{id}",
      )
    end
  end # Real

  class Mock
    def destroy_auto_scaling_group(params={})
      request_id = self.uuid
      url        = params.delete("url")

      auto_scaling_group_id = params["id"] || url && url.split('/').last

      auto_scaling_group = self.data[:auto_scaling_groups][auto_scaling_group_id].dup
      auto_scaling_group["deleted_at"] = Time.now
      auto_scaling_group["resource_url"] = url_for("/auto_scaling_groups/#{auto_scaling_group_id}")

      environment = find(:environments, resource_identity(auto_scaling_group["environment"]))
      environment.delete("auto_scaling_group")

      self.data[:requests][request_id] = {
        "id"          => request_id,
        "finished_at" => nil,
        "successful"  => "true",
        "started_at"  => Time.now,
        "resource"    => [:auto_scaling_groups, auto_scaling_group_id, auto_scaling_group],
        "type"        => "deprovision_auto_scaling_group",
      }

      response(
        :body   => {"request" => {id: request_id}},
        :status => 201,
      )
    end
  end # Mock
end # Ey::Core::Client
