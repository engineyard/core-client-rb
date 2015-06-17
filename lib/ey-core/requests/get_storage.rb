class Ey::Core::Client
  class Real
    def get_storage(params={})
      id  = params["id"]
      url = params["url"]

      request(
        :path => "/storages/#{id}",
        :url  => url,
      )
    end
  end # Real

  class Mock
    def get_storage(params={})
      response(
        :body => {"storage" => self.find(:storages, resource_identity(params))},
      )
    end
  end # Mock
end # Ey::Core::Client
