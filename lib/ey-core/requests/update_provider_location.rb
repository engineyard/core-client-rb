class Ey::Core::Client
  class Real
    def update_provider_location(params={})
      id = params.delete("id")
      request(
        :method => :put,
        :path   => "/provider-locations/#{id}",
        :body   => params,
      )
    end
  end

  class Mock
    def update_provider_location(params={})
      resource_id = params.delete("id")

      if provider_location = self.data[:provider_locations][resource_id]
        provider_location[:limits] = params["provider_location"]["limits"]

        response(
          :body   => {"provider_location" => provider_location},
          :status => 200,
        )
      else
        response(status:404)
      end
    end
  end
end
