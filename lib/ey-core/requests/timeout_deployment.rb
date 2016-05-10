class Ey::Core::Client
  class Real
    def timeout_deployment(params={})
      id  = params.delete("id")
      url = params.delete("url")

      request(
        :body   => params,
        :method => :put,
        :path   => "deployments/#{id}/timeout",
        :url    => url,
      )
    end
  end

  class Mock
    def timeout_deployment(params={})
      deployment = find(:deployments, resource_identity(params))

      deployment["successful"] = false

      self.data[:deployments][deployment["id"]] = deployment

      response(body: {"deployment" => deployment})
    end
  end
end
