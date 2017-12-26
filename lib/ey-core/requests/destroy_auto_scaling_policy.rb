class Ey::Core::Client
  class Real
    def destroy_auto_scaling_policy(params = {})
      id  = params["id"]
      url = params["url"]

      request(
        :method => :delete,
        :url    => url,
        :path   => "/auto_scaling_policies/#{id}",
      )
    end
  end

  class Mock
    def destroy_auto_scaling_policy(params = {})
      request_id = self.uuid
      url        = params.delete("url")

      auto_scaling_policy_id = params["id"] || url && url.split('/').last

      auto_scaling_policy = self.data[:auto_scaling_policies][auto_scaling_policy_id].dup
      auto_scaling_policy.merge!(
        "deleted_at" => Time.now,
        "resource_url" => url_for("/auto_scaling_policies/#{auto_scaling_policy_id}")
      )

      auto_scaling_group = find(
        :auto_scaling_groups,
        resource_identity(auto_scaling_policy["auto_scaling_group"])
      )
      auto_scaling_group.delete("auto_scaling_policy")

      self.data[:requests][request_id] = {
        "id"          => request_id,
        "finished_at" => nil,
        "successful"  => "true",
        "started_at"  => Time.now,
        "resource"    => [:auto_scaling_policies, auto_scaling_policy_id, auto_scaling_policy],
        "type"        => "deprovision_auto_scaling_policy",
      }

      response(
        :body   => { "auto_scaling_policy" => { id: request_id } },
        :status => 201,
      )
    end
  end
end
