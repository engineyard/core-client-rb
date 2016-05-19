class Ey::Core::Client
  class Real
    def change_environment_maintenance(options={})
      id  = options.delete("id")
      url = options.delete("url")

      request(
        :body   => options,
        :method => :put,
        :path   => "environments/#{id}/maintenance",
        :url    => url,
      )
    end
  end

  class Mock
    def change_environment_maintenance(options={})
      find(:environments, resource_identity(params))
      request_id = self.uuid

      request = {
        "id"           => request_id,
        "type"         => "app_deployment_maintenance",
        "successful"   => "true",
        "started_at"   => Time.now,
        "finished_at"  => nil,
        "resource_url" => nil
      }

      self.data[:requests][request_id] = request

      response(
        :body   => {"request" => request},
        :status => 200,
      )
    end
  end
end
