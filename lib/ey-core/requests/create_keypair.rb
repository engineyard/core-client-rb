class Ey::Core::Client
  class Real
    def create_keypair(params={})
      url = params.delete("url")

      request(
        :body   => params,
        :method => :post,
        :path   => "/keypairs",
        :url    => url,
      )
    end
  end # Real

  class Mock
    def create_keypair(params={})
      unless current_user
        return response(status: 403)
      end

      unless params["keypair"]["public_key"]
        return response(status: 422)
      end

      resource_id = self.serial_id

      resource = {
        "id"          => resource_id,
        "application" => nil,
        "fingerprint" => mock_ssh_key[:fingerprint],
        "user"        => url_for("/users/#{current_user["id"]}"),
      }.merge!(params["keypair"])

      self.data[:keypairs][resource_id] = resource

      response(
        :body   => {"keypair" => resource},
        :status => 201,
      )
    end
  end # Mock
end # Ey::Core::Client
