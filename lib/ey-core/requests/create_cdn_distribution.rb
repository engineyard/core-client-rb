class Ey::Core::Client
  class Real
    def create_cdn_distribution(params={})
      url = params.delete("url")

      request(
        :method => :post,
        :path   => "/cdn-distributions",
        :url    => url,
        :body   => params,
      )
    end
  end

  class Mock
    def create_cdn_distribution(params={})
      request_id      = self.uuid
      resource_id     = self.serial_id

      provider_id     = resource_identity(params["provider"])
      environment_id  = resource_identity(params["environment"])
      application_id  = resource_identity(params["application"])

      find(:providers, provider_id)

      resource = params["cdn_distribution"].dup

      resource.merge!(
        "id"             => resource_id,
        "provisioned_id" => SecureRandom.hex(10),
        "resource_url"   => "/cdn-distributions/#{resource_id}",
        "provider"       => url_for("/providers/#{provider_id}"),
        "environment"    => url_for("/environments/#{environment_id}"),
        "application"    => url_for("/applications/#{application_id}"),
        "deleted_at"     => nil,
        "domain"         => Faker::Internet.domain_name,
        "origin"         => Faker::Internet.domain_name
      )

      self.data[:cdn_distributions][resource_id] = resource

      request = {
        "id"          => request_id,
        "type"        => "provision_cdn_distribution",
        "successful"  => "true",
        "started_at"  => Time.now,
        "finished_at" => nil,
        "resource"    => [:cdn_distributions, resource_id, resource],
      }

      self.data[:requests][request_id] = request

      response_hash = request.dup
      response_hash.delete("resource")

      response(
        :body    => {"request" => response_hash},
        :status  => 201,
      )
    end
  end
end
