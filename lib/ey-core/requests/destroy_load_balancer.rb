class Ey::Core::Client
  class Real
    def destroy_load_balancer(params={})
      id  = params["id"]
      url = params.delete("url")

      request(
        :path   => "/load-balancers/#{id}",
        :url    => url,
        :method => :delete,
      )
    end
  end

  class Mock
    def destroy_load_balancer(params={})
      request_id = self.uuid
      url = params.delete("url")

      load_balancer_id = params["id"] || url && url.split('/').last

      self.data[:load_balancers][load_balancer_id]["deleted_at"] = Time.now

      response(
        :body   => {"request" => {id: request_id}},
        :status => 201,
      )
    end
  end
end
