class Ey::Core::Client
  class Real
    def create_firewall(params={})
      url = params.delete("url")

      request(
        :method => :post,
        :path   => "/firewalls",
        :url    => url,
        :body   => params,
      )
    end
  end

  class Mock
    def create_firewall(params={})
      request_id  = self.uuid
      resource_id = self.serial_id

      provider_id = resource_identity(params["provider"])
      cluster_id  = resource_identity(params["cluster"])

      find(:providers, provider_id)

      cluster  = find(:clusters, cluster_id) if cluster_id

      resource = params["firewall"].dup

      resource.merge!(
        "id"             => resource_id,
        "provisioned_id" => SecureRandom.hex(10),
        "resource_url"   => "/firewalls/#{resource_id}",
        "provider"       => url_for("/providers/#{provider_id}"),
        "clusters"       => url_for("/firewalls/#{resource_id}/clusters"),
        "location"       => resource["location"] || cluster["location"],
        "rules"          => url_for("/firewalls/#{resource_id}/rules"),
        "deleted_at"     => nil,
      )

      self.data[:cluster_firewalls] << [cluster_id, resource_id] if cluster_id

      request = {
        "id"          => request_id,
        "type"        => "provision_firewall",
        "successful"  => "true",
        "started_at"  => Time.now,
        "finished_at" => nil,
        "resource"    => [:firewalls, resource_id, resource],
      }

      self.data[:requests][request_id] = request

      response_hash = request.dup
      response_hash.delete("resource")

      response(
        :body    => {"request" => response_hash},
        :status  => 201,
      )
    end
  end
end
