class Ey::Core::Client
  class Real
    def update_auto_scaling_group(params = {})
      id = params.delete("id")

      request(
        :method => :put,
        :path   => "/auto_scaling_groups/#{id}",
        :body   => { "auto_scaling_group" => params.fetch("auto_scaling_group") },
      )
    end
  end

  class Mock
    def update_auto_scaling_group(params = {})
      url = params.delete("url")

      resource_id = params.delete("id")
      resource = find(:auto_scaling_groups, resource_id).merge(params["auto_scaling_group"])

      now = Time.now

      request = {
        "id"           => self.uuid,
        "type"         => "update_auto_scaling_group",
        "successful"   => true,
        "created_at"   => now - 5,
        "updated_at"   => now,
        "started_at"   => now - 3,
        "finished_at"  => now,
        "message"      => nil,
        "read_channel" => nil,
        "resource"     => [:auto_scaling_groups, resource_id, resource],
        "resource_url" => url_for("/auto_scaling_groups/#{resource_id}")
      }

      self.data[:requests][request["id"]] = request

      response(
        :body   => {"request" => request},
        :status => 200
      )
    end
  end
end
