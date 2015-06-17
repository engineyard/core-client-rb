class Ey::Core::Client
  class Real
    def destroy_environment(params={})
      id  = params["id"]
      url = params["url"]

      request(
        :method => :delete,
        :url    => url,
        :path   => "/environments/#{id}",
      )
    end
  end # Real

  class Mock
    def destroy_environment(params={})
      request_id = self.uuid
      url         = params.delete("url")

      environment_id = params["id"] || url && url.split('/').last

      environment = self.data[:environments][environment_id].dup
      environment["deleted_at"] = Time.now
      environment["resource_url"] = url_for("/environments/#{environment_id}")

      # @todo use a procedure to deprovision clusters as well

      self.data[:requests][request_id] = {
        "id"          => request_id,
        "finished_at" => nil,
        "successful"  => "true",
        "started_at"  => Time.now,
        "resource"    => [:environments, environment_id, environment],
        "type"        => "deprovision_environment",
      }

      response(
        :body   => {"request" => {id: request_id}},
        :status => 201,
      )
    end
  end # Mock
end # Ey::Core::Client
