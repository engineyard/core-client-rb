class Ey::Core::Client
  class Real
    def get_feature(params={})
      id  = params["id"]
      url = params["url"]

      request(
        :path => "features/#{id}",
        :url => url,
      )
    end
  end # Real

  class Mock
    def get_feature(params={})
      response(
        :body => {"feature" => self.find(:features, resource_identity(params))},
      )
    end
  end # Mock
end # Ey::Core::Client
