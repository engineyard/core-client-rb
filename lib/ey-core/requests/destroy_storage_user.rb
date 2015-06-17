class Ey::Core::Client
  class Real
    def destroy_storage_user(params={})
      id         = params.delete("id")

      request(
        :method => :delete,
        :path   => "/storage-users/#{id}",
      )
    end
  end # Real

  class Mock
    def destroy_storage_user(params={})
      storage_id = params.delete("storage")
      id         = params.delete("id")

      request_id  = self.uuid

      self.data[:requests][request_id] = {
        "id"          => request_id,
        "type"        => "deprovision_provider_storage_user",
        "successful"  => true,
        "started_at"  => Time.now,
        "finished_at" => nil,
        "resource"    => [:storage_users, id, self.data[:storage_users][id].merge("deleted_at" => Time.now)],
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
