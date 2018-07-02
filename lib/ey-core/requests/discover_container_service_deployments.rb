class Ey::Core::Client
  class Real
    def discover_container_service_deployments(params={})
      url      = params.delete("url")

      request(
        :method => :get,
        :url    => url,
        :params => params,
        :path   => "/container_service_deployments/discover",
      )
    end
  end

  class Mock
    def discover_container_service_deployments(params={})
      extract_url_params!(params)

      callback_url  = params.delete("callback_url")
      deployment_id = self.uuid
      resource_id   = self.uuid

      existing_deploymens = self.data[:container_service_deployments].values.select do |deployment|
        deployment["container_service_id"] == container_service["id"]
      end
      existing_deploymens = nil if existing_deploymens.empty?

      resources = existing_deploymens || [{
        "id"                    => deployment_id,
        "container_service_id"  => params["container_service_id"],
        "public_ip_address"     => "123.456.789.123",
        "private_ip_address"    => "10.0.1.2",
        "container_instance_id" => SecureRandom.uuid,
        "port_mappings"         => [{
          "container_port"      => "80",
          "host_port"           => "80",
          "protocol"            => "tcp"
        }],
        "provisioned_id"        => resource_id,
        "health_status"         => "HEALTHY",
        "task_arn"              => SecureRandom.uuid,
        "container_health_status" => [{
          "container_arn"     => SecureRandom.uuid,
          "health_status"     => SecureRandom.uuid
        }]
      }]

      request = {
        "id" => request_id,
        "type" => "discover_container_service_deployments",
        "successful" => true,
        "started_at" => Time.now,
        "finished_at" => nil,
        "resource" => [:container_service_deployments, resource_id, resources, "/container_service_deployments"]
      }

      self.data[:container_service_deployments][deployment_id] = request

      response_hash = request.dup
      response_hash.delete("resource")

      response(
        :body    => {"request" => response_hash},
        :status  => 200,
        :headers => {
          "Content-Type" => "application/json; charset=utf8"
        }
      )
    end
  end
end
