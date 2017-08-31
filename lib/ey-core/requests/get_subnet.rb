class Ey::Core::Client
  class Real
    def get_subnet(options={})
      id  = options["id"]
      url = options["url"]

      request(
        :path => "subnets/#{id}",
        :url  => url,
      )
    end
  end

  class Mock
    def get_subnet(options={})
      response(
        :body => {"subnet" => self.find(:subnets, resource_identity(options))},
      )
    end
  end
end
