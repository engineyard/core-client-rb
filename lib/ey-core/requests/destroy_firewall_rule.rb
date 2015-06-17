class Ey::Core::Client
  class Real
    def destroy_firewall_rule(params={})
      id  = params["id"]
      url = params.delete("url")

      request(
        :path   => "/firewall-rules/#{id}",
        :url    => url,
        :method => :delete,
      )
    end
  end

  class Mock
    def destroy_firewall_rule(params={})
      extract_url_params!(params)
      request_id = self.uuid

      firewall_rule_id = params["id"] || params["firewall_rule"]

      firewall_rule = self.find(:firewall_rules, firewall_rule_id)

      request = {
        "type"        => "deprovision_firewall_rule",
        "started_at"  => Time.now,
        "finished_at" => nil,
        "successful"  => "true",
        "id"          => request_id,
      }

      self.data[:requests][request_id] = request.merge(
        "resource" => [:firewall_rules, firewall_rule_id, firewall_rule.merge("deleted_at" => Time.now)],
      )

      response(
        :body => {"request" => request},
      )
    end
  end
end
