class Ey::Core::Client
  class Real
    def create_ssl_certificate(params={})
      account_id  = params["account"]
      url         = params.delete("url")

      request(
        :method => :post,
        :url    => url,
        :path   => "/accounts/#{account_id}/ssl_certificates",
        :body   => params
      )
    end
  end # Real

  class Mock
    def create_ssl_certificate(params={})
      url = params.delete("url")
      account_id = params["account"] || url && path_params(url)["accounts"]

      find(:accounts, account_id)

      resource_id = self.uuid

      resource = params["ssl_certificate"].dup

      if resource.delete("self_sign")
        key  = OpenSSL::PKey::RSA.new(1024)
        name = OpenSSL::X509::Name.parse("/CN=example.org")

        # NB: the order in which these attributes are set seems to be
        # important in making it self-signed and not just a certificate
        # with a mystery issuer. It's not clear which attributes have
        # the ordering requirement.
        cert = OpenSSL::X509::Certificate.new
        cert.version    = 2
        cert.serial     = Time.now.tv_sec            # monotonically increasing
        cert.not_before = Time.now - (7 * 24 * 60 * 60) # allow for plenty of clock skew
        cert.not_after  = Time.now + (10 * 356 * 24 * 60 * 60) # allow for plenty of clock skew
        cert.subject    = name
        cert.public_key = key.public_key
        cert.issuer     = name

        cert.sign(key, OpenSSL::Digest::SHA1.new)

        resource["public_certificate"] = cert.to_pem
        resource["private_key"]        = key.to_pem
        resource["self_signed"]        = true
      elsif ! resource['public_certificate'] or ! resource['private_key']
        return response(status: 422, body: {"errors" => ["public_certificate and private_key must not be blank."]})
      end

      resource.merge!(
        "account"      => url_for("/accounts/#{account_id}"),
        "created_at"   => Time.now,
        "id"           => resource_id,
        "updated_at"   => Time.now,
        "resource_url" => url_for("/ssl_certificates/#{resource_id}"),
      )

      request = {
        "account"      => url_for("/accounts/#{account_id}"),
        "created_at"   => Time.now,
        "finished_at"  => nil,
        "id"           => self.uuid,
        "message"      => nil,
        "read_channel" => nil,
        "resource"     => [:ssl_certificates, resource_id, resource],
        "started_at"   => Time.now,
        "successful"   => true,
        "type"         => "provision_ssl_certificate",
        "updated_at"   => Time.now,
      }

      self.data[:requests][request["id"]] = request

      response(
        :body    => {"request" => request},
        :status  => 201
      )
    end
  end # Mock
end # Ey::Core::Client
