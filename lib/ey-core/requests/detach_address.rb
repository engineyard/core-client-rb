class Ey::Core::Client
  class Real
    def detach_address(params={})
      id = params["id"]

      request(
        :method => :put,
        :path   => "addresses/#{id}/detach",
      )
    end
  end # Real

  class Mock
    def detach_address(params={})
      resource_id = params.delete("id")
      request_id  = self.uuid

      resource = self.data[:addresses][resource_id]
      server_id = resource["server_url"].split("/").last.to_i
      server = self.data[:servers][server_id]

      server["address_url"] = nil
      resource["server_url"] = nil

      request = {
        "id"          => request_id,
        "type"        => "detach_address",
        "successful"  => "true",
        "started_at"  => Time.now,
        "finished_at" => nil,
        "resource"    => [:addresses, resource_id, resource],
      }

      self.data[:requests][request_id] = request

      response_hash = request.dup
      response_hash.delete("resource")

      response(
        :body    => {"request" => response_hash},
        :status  => 200,
        :headers => {
          "Content-Type" => "application/json; charset=utf8"
        }
      )
    end
  end # Mock
end # Ey::Core::Client
