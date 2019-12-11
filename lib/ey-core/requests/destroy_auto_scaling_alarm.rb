class Ey::Core::Client
  class Real
    def destroy_auto_scaling_alarm(params = {})
      id  = params["id"]
      url = params["url"]

      request(
        :method => :delete,
        :url    => url,
        :path   => "/auto_scaling_alarms/#{id}",
      )
    end
  end

  class Mock
    def destroy_auto_scaling_alarm(params = {})
      request_id = self.uuid
      url        = params.delete("url")

      auto_scaling_alarm_id = params["id"] || url && url.split('/').last

      auto_scaling_alarm = self.data[:auto_scaling_alarms][auto_scaling_alarm_id]
      auto_scaling_alarm.merge!(
        "deleted_at" => Time.now,
        "resource_url" => url_for("/auto_scaling_alarms/#{auto_scaling_alarm_id}")
      )

      auto_scaling_policy = find(
        :auto_scaling_policies,
        resource_identity(auto_scaling_alarm["auto_scaling_policy"])
      )
      auto_scaling_policy.delete("auto_scaling_alarm")

      self.data[:requests][request_id] = {
        "id"          => request_id,
        "finished_at" => nil,
        "successful"  => "true",
        "started_at"  => Time.now,
        "resource"    => [:auto_scaling_alarms, auto_scaling_alarm_id, auto_scaling_alarm],
        "type"        => "deprovision_auto_scaling_alarm",
      }

      response(
        body:   { "request" => self.data[:requests][request_id] },
        status: 201
      )
    end
  end
end
