class Ey::Core::Client
  class Real
    def restart_environment_app_servers(params={})
      id = params.delete("id")
      url = params.delete("url")

      request(
        :body   => params,
        :method => :put,
        :path   => "environments/#{id}/app_restart",
        :url    => url,
      )
    end
  end

  class Mock
    def restart_environment_app_servers(params={})
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
