class Ey::Core::Client
  class Real
    def get_deployment(params={})
      id  = params.delete("id")
      url = params.delete("url")

      request(
        :path => "deployments/#{id}",
        :url  => url,
      )
    end
  end

  class Mock
    def get_deployment(params={})
      response(body: {"deployment" => find(:deployments, resource_identity(params))})
    end
  end
end
