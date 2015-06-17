class Ey::Core::Client
  class Real
    def get_firewall_rule(params={})
      id  = params["id"]
      url = params["url"]

      request(
        :path => "/firewall-rules/#{id}",
        :url  => url,
      )
    end
  end

  class Mock
    def get_firewall_rule(params={})
      response(
        :body => {"firewall_rule" => self.find(:firewall_rules, resource_identity(params))},
      )
    end
  end
end
