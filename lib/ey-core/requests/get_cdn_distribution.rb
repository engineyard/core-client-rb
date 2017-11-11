class Ey::Core::Client
  class Real
    def get_cdn_distribution(params={})
      id  = params["id"]
      url = params["url"]

      request(
        :path => "/cdn-distributions/#{id}",
        :url  => url,
      )
    end
  end

  class Mock
    def get_cdn_distribution(params={})
      response(
        :body => {"cdn_distribution" => self.find(:cdn_distributions, resource_identity(params))},
      )
    end
  end
end
