class Ey::Core::Client
  class Real
    def get_address(params={})
      id  = params["id"]
      url = params["url"]

      request(
        :path => "addresses/#{id}",
        :url  => url
      )
    end
  end # Real

  class Mock
    def get_address(params={})
      identity = resource_identity(params)

      address = self.data[:addresses][identity]

      response(
        :body => {"address" => address},
      )
    end
  end # Mock
end # Ey::Core::Client
