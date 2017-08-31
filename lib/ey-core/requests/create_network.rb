class Ey::Core::Client
  class Real
    def create_network(options={})
      request(
        :method => :post,
        :path   => "/networks",
        :params => options,
      )
    end
  end

  class Mock
    def create_network(options={})
      request_id = self.uuid
      resource_id = self.uuid
      provider_id = options["provider"]

      self.find(:providers, provider_id)

      resource = options["network"].dup
      skip_subnets = resource.delete("skip_subnets")
      resource.merge!(
        "id"             => resource_id,
        "provisioned_id" => "vpc-#{SecureRandom.hex(4)}",
        "resource_url"   => "/networks/#{resource_id}",
        "provider"       => url_for("/providers/#{provider_id}")
      )

      request = {
        "id"          => request_id,
        "type"        => "provision_network",
        "successful"  => true,
        "started_at"  => Time.now,
        "finished_at" => nil,
        "resource"    => [:networks, resource_id, resource],
      }

      unless skip_subnets
        cidr_object = NetAddr::CIDR.create(resource["cidr"])
        possible_subnets = cidr_object.subnet(Bits: 24, NumSubnets: 5)[0..4]

        ('a'..'e').to_a.each_with_index do |l, i|
          subnet_id = self.uuid
          self.data[:subnets][subnet_id] = {
            "id"             => subnet_id,
            "cidr"           => possible_subnets[i],
            "location"       => l,
            "network"        => url_for("/networks/#{resource_id}"),
            "provisioned_id" => "subnet-#{SecureRandom.hex(4)}",
          }
        end
      end

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
