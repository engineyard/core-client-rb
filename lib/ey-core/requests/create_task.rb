class Ey::Core::Client
  class Real
    def create_task(params={})
      cluster_component_id  = params.delete("cluster_component")
      url = params.delete("url")

      request(
        :body   => params,
        :method => :post,
        :path   => "/cluster_components/#{cluster_component_id}/tasks",
        :url    => url,
      )
    end
  end # Real

  class Mock
    def create_task(params={})
      request_id = self.uuid
      resource_id = self.uuid
      url = params["url"]

      cluster_component_id = url && path_params(url)["cluster_components"]
      cluster_component_id ||= params.delete("cluster_component")

      self.find(:cluster_components, cluster_component_id)

      task = {
        "finished_at"       => nil,
        "id"                => request_id,
        "started_at"        => Time.now,
        "successful"        => true,
        "read_channel"      => "https://messages.engineyard.com/stream?subscription=/tasks/#{request_id[0..7]}&token=#{SecureRandom.hex(6)}",
        "cluster_component" => url_for("/cluster-components/#{cluster_component_id}"),
      }

      request = task.merge(
        "resource"    => [:tasks, resource_id, task],
        "type"        => "task",
        "finished_at" => nil,
        "successful"  => nil,
      )

      self.data[:requests][request_id] = request
      self.data[:tasks][request_id]    = task

      response_hash = request.dup
      response_hash.delete("resource")

      response(
        :body   => {"request" => response_hash},
        :status => 201,
      )
    end
  end # Mock
end # Ey::Core::Client
