class Ey::Core::Client
  class Real
    def destroy_ssl_certificate(params={})
      id  = params["id"]
      url = params.delete("url")

      request(
        :method => :delete,
        :path => "ssl_certificates/#{id}",
        :url  => url,
      )
    end
  end

  class Mock
    def destroy_ssl_certificate(params={})
      url = params.delete("url")

      ssl_certificate_id = params["id"] || url_params(url)["ssl_certificates"]
      self.data[:ssl_certificates][ssl_certificate_id]["deleted_at"] = Time.now

      response(
        :body   => nil,
        :status => 204,
      )
    end
  end
end
