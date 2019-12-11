class Ey::Core::Client
  class Real
    def discover_server(options={})
      provider_id = options.delete("provider")

      request(
        :method => :post,
        :path   => "/providers/#{provider_id}/servers/discover",
        :body   => options
      )
    end
  end

  class Mock
    def discover_server(options={})
      options = Cistern::Hash.stringify_keys(options)

      provider_id = options.delete("provider")
      request_id = self.uuid

      options["server"]["role"] ||= "app"
      options["server"]["flavor"] ||= "m4.large"

      server = self.data[:servers].values.detect do |s|
        !s["deleted_at"] && s["provider"] == url_for("/providers/#{provider_id}") && s["provisioned_id"] == options["server"]["provisioned_id"]
      end

      resource = if server
                   server
                 else
                   if auto_scaling_group_id = options["auto_scaling_group"]
                     find(:auto_scaling_groups, auto_scaling_group_id)
                   end

                   s = self.requests.new(create_server(options).body["request"]).resource! # cheating
                   self.data[:servers][s.id]
                 end

      request = {
        "id"           => request_id,
        "type"         => "discover_server",
        "successful"   => true,
        "started_at"   => Time.now,
        "finished_at"  => nil,
        "resource_url" => url_for("/servers/#{resource["id"]}"),
        "resource"     => [:servers, resource["id"], resource],
      }

      self.data[:requests][request_id] = request

      response_hash = request.dup
      response_hash.delete("resource")

      response(
        :body   => {"request" => response_hash},
        :status => 201,
      )
    end
  end
end
