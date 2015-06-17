class Ey::Core::Client
  class Real
    def get_ssl_certificate(params={})
      id  = params["id"]
      url = params["url"]

      request(
        :path => "ssl_certificates/#{id}",
        :url  => url,
      )
    end
  end # Real

  class Mock
    def get_ssl_certificate(params={})
      identity = resource_identity(params)

      response(
        :body => {"ssl_certificate" => self.find(:ssl_certificates, identity)},
      )
    end
  end # Mock
end # Ey::Core::Client
