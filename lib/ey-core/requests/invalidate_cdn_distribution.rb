class Ey::Core::Client
  class Real
    def invalidate_cdn_distribution(params={})
      id  = params.delete("id")
      url = params.delete("url")

      request(
        :path   => "/cdn-distributions/#{id}/invalidate",
        :url    => url,
        :method => :put,
        :body   => params
      )
    end
  end

  class Mock
    def invalidate_cdn_distribution(_params={})
      request_id = self.uuid

      response(
        :body   => {"request" => {id: request_id}},
        :status => 201,
      )
    end
  end
end
