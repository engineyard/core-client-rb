class Ey::Core::Client
  class Real
    def apply_environment_updates(options={})
      id  = options.delete("id")
      url = options.delete("url")

      request(
        :path   => "environments/#{id}/apply",
        :method => :post,
        :url    => url,
        :body   => options,
      )
    end
  end

  class Mock
    def apply_environment_updates(options={})
      id          = options.delete("id")
      servers     = get_servers("environment" => id).body["servers"]
      request_id  = self.uuid

      servers.each do |server|
        update_id = self.uuid
        self.data[:instance_updates][update_id] = {
          "id"          => update_id,
          "instance_id" => server["id"],
          "data"        => {
            "type" => options["type"] || "main",
          }
        }
      end

      request = {
        "id"           => request_id,
        "type"         => "configure_environment",
        "successful"   => true,
        "started_at"   => Time.now,
        "finished_at"  => Time.now,
        "resource_url" => nil,
        "resource"     => nil,
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
