class Ey::Core::Client
  class Real
    def create_auto_scaling_policy(options = {})
      params = Cistern::Hash.stringify_keys(options)
      url = params.delete("url")
      auto_scaling_group_id = params.delete("auto_scaling_group_id")
      body = {
        auto_scaling_policy: params,
        auto_scaling_group_id: auto_scaling_group_id
      }

      request(
        :method => :post,
        :url    => url,
        :path   => "/auto_scaling_groups",
        :body   => body
      )
    end
  end

  class Mock
    def create_auto_scaling_policy(options = {})
      params = Cistern::Hash.stringify_keys(options)
      url = params.delete("url")

      auto_scaling_group_id = params.delete("auto_scaling_group")
      auto_scaling_group = find(:auto_scaling_groups, auto_scaling_group_id)
      id = self.uuid
      resource = params["auto_scaling_policy"].dup
      arn = "scalingPolicy:00000000-0000-0000-0000-000000000000:autoScalingGroupName/#{auto_scaling_group['name']}:policyName/#{resource['name']}"

      now = Time.now

      resource.merge!(
        "created_at"         => now,
        "auto_scaling_group" => url_for("/auto_scaling_groups/#{auto_scaling_group_id}"),
        "id"                 => id,
        "arn"                => arn,
        "resource_url"       => url_for("/auto_scaling_policies/#{id}")
      )

      self.data[:auto_scaling_policies][id] = resource
      environment.merge!("auto_scaling_policy" => url_for("/auto_scaling_policies/#{id}"))

      self.data[:requests][id] = resource

      response(
        :body   => { "auto_scaling_policy" => resource },
        :status => 200
      )
    end
  end
end
