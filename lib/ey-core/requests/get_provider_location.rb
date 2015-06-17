class Ey::Core::Client
  class Real
    def get_provider_location(params={})
      id  = params.delete("id")
      url = params.delete("url")

      request(
        :path => "/provider-locations/#{id}",
        :url  => url
      )
    end
  end

  class Mock
    def get_provider_location(params={})
      extract_url_params!(params)

      identity = params["id"] || params["provider_location"]

      provider_location = self.find(:provider_locations, identity)
      body = provider_location.dup
      body.delete("name")

      response(
        :body => {"provider_location" => body},
      )
    end
  end
end
