class Ey::Core::Client
  class Real
    def apply_server_updates(options={})
      id  = options.delete("id")
      url = options.delete("url")

      request(
        :path   => "servers/#{id}/apply",
        :method => :post,
        :url    => url,
        :body   => options,
      )
    end
  end

  class Mock
    def apply_server_updates(options={})
      id         = options.delete("id")
      server     = self.data[:servers][id]
      request_id = self.uuid
      update_id  = self.uuid

      self.data[:instance_updates][update_id] = {
        "id"          => update_id,
        "instance_id" => server["id"],
        "data"        => {
          "type" => options["type"] || "main",
        }
      }

      request = {
        "id"           => request_id,
        "type"         => "instance_update",
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
