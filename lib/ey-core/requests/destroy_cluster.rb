class Ey::Core::Client
  class Real
    def destroy_cluster(id)
      request(
        :method => :delete,
        :path => "/clusters/#{id}"
      )
    end
  end

  class Mock
    def destroy_cluster(id)
      request_id = self.uuid

      self.data[:requests][request_id] = {
        "id"          => request_id,
        "finished_at" => nil,
        "successful"  => "true",
        "started_at"  => Time.now,
        "resource"    => [:clusters, id, self.data[:clusters][id].merge("deleted_at" => Time.now)],
        "type"        => "deprovision_cluster",
      }

      response(
        :body   => {"request" => {id: request_id}},
        :status => 201,
      )
    end
  end
end
