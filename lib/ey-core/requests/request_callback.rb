class Ey::Core::Client
  class Real
    def request_callback(id)
      request(
        :path   => "/requests/#{id}/callback",
        :method => :post
      )
    end
  end

  class Mock
    def request_callback(id)
      request_id = self.uuid

      request = find(:requests, id).dup
      request.delete("resource")

      response(
        :body   => {"request" => request},
        :status => 200,
      )
    end
  end
end
