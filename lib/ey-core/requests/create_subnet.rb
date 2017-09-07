class Ey::Core::Client
  class Real
    def create_subnet(options={})
      query = Ey::Core.paging_parameters(options)
      url   = options.delete("url")

      request(
        :method => :post,
        :path   => "/subnets",
        :params => options,
      )
    end
  end

  class Mock
    def create_subnet(options={})
      request_id = self.uuid
      resource_id = self.uuid
      network_id = options["network"]

      self.find(:networks, network_id)

      resource = options["subnet"].dup
      resource.merge!(
        "id"             => resource_id,
        "provisioned_id" => "subnet-#{SecureRandom.hex(4)}",
        "resource_url"   => "/subnets/#{resource_id}",
        "network"        => url_for("/networks/#{network_id}")
      )

      request = {
        "id"          => request_id,
        "type"        => "provision_subnet",
        "successful"  => true,
        "started_at"  => Time.now,
        "finished_at" => nil,
        "resource"    => [:subnets, resource_id, resource],
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
  end
end
