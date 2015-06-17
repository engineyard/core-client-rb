class Ey::Core::Client::SslCertificates < Ey::Core::Collection

  model Ey::Core::Client::SslCertificate

  self.model_root         = "ssl_certificate"
  self.model_request      = :get_ssl_certificate
  self.collection_root    = "ssl_certificates"
  self.collection_request = :get_ssl_certificates
end
