class Ey::Core::Client
  class Real
    def attach_address(params={})
      id = params.delete("id")

      request(
        :method => :put,
        :path   => "addresses/#{id}/attach",
        :params => params,
      )
    end
  end # Real

  class Mock
    def attach_address(params={})
      resource_id = params.delete("id")
      server_id   = params.delete("server").to_i
      request_id  = self.uuid

      server = self.find(:servers, server_id)
      server.merge!(
        "address_url" => "/addresses/#{resource_id}",
      )

      resource = self.data[:addresses][resource_id]
      resource.merge!(
        "server_url" => "/servers/#{server_id}",
      )

      request = {
        "id"          => request_id,
        "type"        => "attach_address",
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
