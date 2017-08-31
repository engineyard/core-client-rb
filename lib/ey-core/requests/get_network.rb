class Ey::Core::Client
  class Real
    def get_network(options={})
      id  = options["id"]
      url = options["url"]

      request(
        :path => "networks/#{id}",
        :url  => url,
      )
    end
  end

  class Mock
    def get_network(options={})
      response(
        :body => {"network" => self.find(:networks, resource_identity(options))},
      )
    end
  end
end
