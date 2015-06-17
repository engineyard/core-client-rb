class Ey::Core::Client
  class Real
    def destroy_provider(id)
      request(
        :method => :delete,
        :path   => "/providers/#{id}",
      )
    end
  end

  class Mock
    def destroy_provider(id)
      provider   = self.data[:providers][id].dup
      request_id = self.uuid

      provider["cancelled_at"] = Time.now
      provider["resource_url"] = url_for("/providers/#{id}")

      self.data[:requests][request_id] = {
        "id"          => request_id,
        "finished_at" => nil,
        "successful"  => "true",
        "started_at"  => Time.now,
        "resource"    => [:providers, id, provider],
        "type"        => "cancel_provider",
      }

      response(
        :body   => {"request" => {id: request_id}},
        :status => 201,
      )
    end
  end
end
