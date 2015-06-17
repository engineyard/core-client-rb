class Ey::Core::Client
  class Real
    def create_untracked_server(params={})
      request(
        :body   => params,
        :method => :post,
        :path   => "/untracked-servers",
        :url    => params.delete("url"),
      )
    end
  end # Real

  class Mock
    def create_untracked_server(params={})
      resource_id = self.serial_id
      url         = params["url"]

      provider_id ||= params["provider"] || (url && path_params(url)["providers"])

      find(:providers, provider_id)

      resource = params["untracked_server"].dup

      require_parameters(resource, "location", "provisioned_id", "provisioner_id")

      resource.merge!(
        "provider" => url_for("/providers/#{provider_id}"),
        "id"       => resource_id,
      )

      self.data[:untracked_servers][resource_id] = resource

      response(
        :body   => { "untracked_server" => resource },
        :status => 201,
      )
    end
  end # Mock
end # Ey::Core::Client
