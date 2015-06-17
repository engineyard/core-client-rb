class Ey::Core::Client
  class Real
    def create_firewall_rule(params={})
      firewall = params.delete("firewall")
      url      = params.delete("url")

      request(
        :method => :post,
        :path   => "/firewalls/#{firewall}/rules",
        :url    => url,
        :body   => params,
      )
    end
  end

  class Mock
    def create_firewall_rule(params={})
      request_id = self.uuid
      resource_id = self.serial_id

      firewall_id = resource_identity(params["firewall"])

      find(:firewalls, firewall_id)

      source = params["firewall_rule"]["source"] or return response(status: 422, body: { "errors" => ["missing firewall rule source"] })
      range  = params["firewall_rule"]["port_range"] or return response(status: 422, body: { "errors" => ["missing firewall rule port_range"] })

      resource = {
        "id"           => resource_id,
        "source"       => source.to_s,
        "port_range"   => range.to_s,
        "firewall"     => url_for("/firewalls/#{firewall_id}"),
        "resource_url" => "/firewall-rules/#{resource_id}",
      }

      request = {
        "id"          => request_id,
        "type"        => "provision_firewall_rule",
        "successful"  => "true",
        "started_at"  => Time.now,
        "finished_at" => nil,
        "resource"    => [:firewall_rules, resource_id, resource],
      }

      self.data[:requests][request_id] = request

      response_hash = request.dup

      response_hash.delete("resource")

      response(
        :body    => {"request" => response_hash},
        :status  => 201,
        :headers => {
          "Content-Type" => "application/json; charset=utf8"
        }
      )
    end
  end
end
