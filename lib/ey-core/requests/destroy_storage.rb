class Ey::Core::Client
  class Real
    def destroy_storage(id)
      request(
        :method => :delete,
        :path   => "/storages/#{id}",
      )
    end
  end # Real

  class Mock
    def destroy_storage(id)
      request_id  = self.uuid

      self.data[:requests][request_id] = {
        "id"          => request_id,
        "type"        => "deprovision_provider_storage",
        "successful"  => true,
        "started_at"  => Time.now,
        "finished_at" => nil,
        "resource"    => [:storages, id, self.data[:storages][id].merge("deleted_at" => Time.now)],
      }

      response(
        :body    => {"request" => {id: request_id}},
        :status  => 201,
        :headers => {
          "Content-Type" => "application/json; charset=utf8",
        }
      )
    end
  end # Mock
end
