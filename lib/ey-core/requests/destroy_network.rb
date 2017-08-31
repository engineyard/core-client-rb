class Ey::Core::Client
  class Real
    def destroy_network(options={})
      id = options.delete("id")
      url = options.delete("url")

      request(
        :method => :delete,
        :path   => "/networks/#{id}",
        :url    => url,
      )
    end
  end

  class Mock
    def destroy_network(options={})
      extract_url_params!(options)
      request_id = self.uuid
      network_id = options["id"]

      network = find(:networks, network_id)

      request = {
        "type"        => "deprovision_network",
        "started_at"  => Time.now,
        "finished_at" => nil,
        "successful"  => true,
        "id"          => request_id
      }

      resource =

      self.data[:requests][request_id] = request.merge(
        "resource" => [:networks, network_id, network.merge("deleted_at" => Time.now)],
      )

      response(
        :body => {"request" => request},
      )
    end
  end
end
