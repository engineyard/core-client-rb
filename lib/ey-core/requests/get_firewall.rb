class Ey::Core::Client
  class Real
    def get_firewall(params={})
      id  = params["id"]
      url = params["url"]

      request(
        :path => "firewalls/#{id}",
        :url  => url,
      )
    end
  end

  class Mock
    def get_firewall(params={})
      response(
        :body => {"firewall" => self.find(:firewalls, resource_identity(params))},
      )
    end
  end
end
