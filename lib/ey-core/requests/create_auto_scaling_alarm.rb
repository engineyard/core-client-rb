class Ey::Core::Client
  class Real
    def create_auto_scaling_alarm(options = {})
      params = Cistern::Hash.stringify_keys(options)

      url = params.delete("url")
      auto_scaling_policy_id = params["auto_scaling_policy_id"]

      body = {
        auto_scaling_alarm: params,
        auto_scaling_policy_id: auto_scaling_policy_id
      }

      request(
        :method => :post,
        :url    => url,
        :path   => "/auto_scaling_policies/auto_scaling_alarms",
        :body   => body
      )
    end
  end

  class Mock
    def create_auto_scaling_alarm(options = {})
      params = Cistern::Hash.stringify_keys(options)

      request_id  = self.serial_id
      resource_id = self.uuid

      auto_scaling_policy_id = params.delete("auto_scaling_policy_id")
      auto_scaling_policy = find(:auto_scaling_policies, auto_scaling_policy_id)

      resource = params["auto_scaling_alarm"].dup
      arn = "arn:aws:cloudwatch:eu-west-1:000000000000:metricAlarm:00000000-0000-0000-0000-000000000000:alarmName/#{resource["name"]}"

      now = Time.now

      resource.merge!(
        "id"                  => resource_id,
        "created_at"          => now,
        "auto_scaling_policy" => auto_scaling_policy["id"],
        "provisioned_id"      => arn,
        "resource_url"        => url_for("/auto_scaling_alarms/#{resource_id}")
      )

      request = {
        "id"           => request_id,
        "created_at"   => now - 2,
        "updated_at"   => now,
        "started_at"   => now - 1,
        "finished_at"  => now,
        "message"      => nil,
        "read_channel" => nil,
        "resource"     => [:auto_scaling_alarms, resource_id, resource],
        "resource_url" => url_for("/auto_scaling_alarms/#{resource_id}"),
        "type"         => "provision_auto_scaling_alarm",
        "successful"   => true,
      }

      self.data[:auto_scaling_alarms][resource_id] = resource
      self.data[:requests][request_id] = request

      response(
        :body   => { "request" => request },
        :status => 200
      )
    end
  end
end
