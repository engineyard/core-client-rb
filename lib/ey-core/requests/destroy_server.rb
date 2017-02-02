class Ey::Core::Client
  class Real
    def destroy_server(id,options={})
      
      request(
        :method => :delete,
        :path => "/servers/#{id}",
        :query => options
      )
    end
  end

  class Mock
    def destroy_server(id)
      deprovision_procedure = lambda do |_|
        server = self.data[:servers][id]

        server.merge!("deleted_at" => Time.now, "deprovisioned_at" => Time.now)

        if slot_id = resource_identity(server["slot"])
          self.data[:slots][slot_id]["server"] = nil
        end

        self.data[:volumes].values.select {|v| v["server"] == url_for("/servers/#{id}") }.each do |volume|
          volume.merge!("deleted_at" => Time.now)
        end

        nil
      end

      request_id = self.uuid

      self.data[:requests][request_id] = {
        "id"          => request_id,
        "finished_at" => nil,
        "successful"  => "true",
        "started_at"  => Time.now,
        "resource"    => [:servers, id, deprovision_procedure],
        "type"        => "deprovision_server",
      }

      response(
        :body   => {"request" => {id: request_id}},
        :status => 201,
      )
    end
  end
end
