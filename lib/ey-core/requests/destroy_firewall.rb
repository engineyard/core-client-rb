class Ey::Core::Client
  class Real
    def destroy_firewall(params={})
      id  = params["id"]
      url = params.delete("url")

      request(
        :path   => "/firewalls/#{id}",
        :url    => url,
        :method => :delete,
      )
    end
  end

  class Mock
    def destroy_firewall(params={})
      extract_url_params!(params)
      request_id = self.uuid

      firewall_id = params["id"] || params["firewall"]

      firewall = self.find(:firewalls, firewall_id)

      request = {
        "type"        => "deprovision_firewall",
        "started_at"  => Time.now,
        "finished_at" => nil,
        "successful"  => "true",
        "id"          => request_id,
      }

      self.data[:requests][request_id] = request.merge(
        "resource"    => [:firewalls, firewall_id, firewall.merge("deleted_at" => Time.now)],
      )

      response(
        :body => {"request" => request},
      )
    end
  end
end
