class Ey::Core::Client
  class Real
    def destroy_subnet(options={})
      id = options.delete("id")
      url = options.delete("url")

      request(
        :method => :delete,
        :path   => "/subnets/#{id}",
        :url    => url,
      )
    end
  end

  class Mock
    def destroy_subnet(options={})
      extract_url_params!(options)
      request_id = self.uuid
      subnet_id = options["id"]

      subnet = find(:subnets, subnet_id)

      request = {
        "type"        => "deprovision_subnet",
        "started_at"  => Time.now,
        "finished_at" => nil,
        "successful"  => true,
        "id"          => request_id
      }

      self.data[:requests][request_id] = request.merge(
        "resource" => [:subnets, subnet_id, subnet.merge("deleted_at" => Time.now)],
      )

      response(
        :body => {"request" => request},
      )
    end
  end
end
