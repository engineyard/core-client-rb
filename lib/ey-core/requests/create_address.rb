class Ey::Core::Client
  class Real
    def create_address(params={})
      request(
        :method => :post,
        :path   => "/addresses",
        :params => params,
      )
    end
  end # Real

  class Mock
    def create_address(params={})
      request_id  = self.uuid
      resource_id = self.serial_id
      provider_id = params["provider"]

      self.find(:providers, provider_id)

      resource = params["address"].dup
      ip_address = self.ip_address
      resource.merge!(
        "id"             => resource_id,
        "provisioned_id" => ip_address,
        "ip_address"     => ip_address,
        "resource_url"   => "/addresses/#{resource_id}",
        "provider"       => url_for("/providers/#{provider_id}")
      )

      request = {
        "id"          => request_id,
        "type"        => "provision_address",
        "successful"  => "true",
        "started_at"  => Time.now,
        "finished_at" => nil,
        "resource"    => [:addresses, resource_id, resource],
      }

      self.data[:requests][request_id] = request

      response_hash = request.dup
      response_hash.delete("resource")

      response(
        :body    => {"request" => response_hash},
        :status  => 201,
        :headers => {
          "Content-Type" => "application/json; charset=utf8"
        }
      )
    end
  end # Mock
end # Ey::Core::Client
