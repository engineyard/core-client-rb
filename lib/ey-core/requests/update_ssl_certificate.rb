class Ey::Core::Client
  class Real
    def update_ssl_certificate(params={})
      id = params.delete("id")

      request(
        :method => :put,
        :path   => "/ssl_certificates/#{id}",
        :body   => params,
      )
    end
  end

  class Mock
    def update_ssl_certificate(params={})
      ssl_certificate = self.find(:ssl_certificates, resource_identity(params))

      ssl_certificate.merge!(params["ssl_certificate"])

      response(
        :body => {"ssl_certificate" => ssl_certificate}
      )
    end
  end
end
