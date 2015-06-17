class Ey::Core::Client
  class Real
    def create_load_balancer(params={})
      url = params.delete("url")

      request(
        :method => :post,
        :path   => "/load-balancers",
        :url    => url,
        :body   => params,
      )
    end
  end # Real

  class Mock
    def create_load_balancer(params={})
      request_id  = self.uuid
      resource_id = self.serial_id

      provider_id    = params.delete("provider")
      firewall_id    = params.delete("firewall")

      find(:providers, provider_id)
      find(:firewalls, firewall_id) if firewall_id

      resource = params["load_balancer"].dup

      resource.merge!(
        "id"             => resource_id,
        "provisioned_id" => SecureRandom.hex(10),
        "resource_url"   => "/load_balancers/#{resource_id}",
        "provider"       => url_for("/providers/#{provider_id}"),
        "location"       => resource["location"],
        "name"           => resource["name"],
      )
      resource.merge!("firewall" => url_for("/firewalls/#{firewall_id}")) if firewall_id

      request = {
        "id"          => request_id,
        "type"        => "provision_load_balancer",
        "successful"  => true,
        "started_at"  => Time.now,
        "finished_at" => nil,
        "resource"    => [:load_balancers, resource_id, resource],
      }

      self.data[:requests][request_id] = request
      self.data[:load_balancers][resource_id] = resource

      response_hash = request.dup
      response_hash.delete("resource")

      response(
        :body => {"request" => response_hash},
        :status => 201,
        :headers => {
          "Content-Type" => "application/json; charset=utf8",
        }
      )
    end
  end # Mock
end
