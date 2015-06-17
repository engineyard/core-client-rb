class Ey::Core::Client
  class Real
    def create_keypair_deployment(params={})
      url            = params.delete("url")
      keypair_id     = params["keypair"]
      environment_id = params["environment"]

      request(
        :method => :post,
        :path   => "/environments/#{environment_id}/keypairs/#{keypair_id}",
        :url    => url,
      )
    end
  end  #  Real

  class Mock
    def create_keypair_deployment(params={})
      resource_id    = self.serial_id
      keypair_id     = params["keypair"]
      environment_id = params["environment"]

      resource  =  {
        "id"      => resource_id,
        "keypair" => url_for("/keypairs/#{keypair_id}"),
        "target"  => url_for("/environments/#{environment_id}"),
      }

      self.data[:keypair_deployments][resource_id] = resource

      response(
        :body   => {"keypair_deployment" => resource},
        :status => 201,
      )
    end
  end # Mock
end # Ey::Core::Client
