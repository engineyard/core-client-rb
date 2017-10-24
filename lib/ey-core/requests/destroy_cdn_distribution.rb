class Ey::Core::Client
  class Real
    def destroy_cdn_distribution(params={})
      id  = params["id"]
      url = params.delete("url")

      request(
        :path   => "/cdn-distributions/#{id}",
        :url    => url,
        :method => :delete,
      )
    end
  end

  class Mock
    def destroy_cdn_distribution(params={})
      request_id = self.uuid
      url = params.delete("url")

      cdn_distribution_id = params["id"] || url && url.split('/').last

      self.data[:cdn_distributions][cdn_distribution_id]["deleted_at"] = Time.now

      response(
        :body   => {"request" => {id: request_id}},
        :status => 201,
      )
    end
  end
end
