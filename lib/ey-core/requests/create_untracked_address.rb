class Ey::Core::Client
  class Real
    def create_untracked_address(params={})
      request(
        :body   => params,
        :method => :post,
        :path   => "/untracked-addresses",
        :url    => params.delete("url"),
      )
    end
  end # Real

  class Mock
    def create_untracked_address(params={})
      url         = params["url"]

      provider_id ||= params["provider"] || (url && path_params(url)["providers"])
      find(:providers, provider_id)

      resource = params["untracked_address"].dup

      require_parameters(resource, "location", "provisioned_id", "provisioner_id")
      existing_address = self.data[:addresses].find {|id, a| a['provisioned_id'] == resource["provisioned_id"] }

      if existing_address
        existing_id, existing_address = existing_address
        response(
          :body => {"errors" => ["Address '#{resource['provisioned_id']}' is tracked."],
                    "address" => url_for("/addresses/#{existing_id}")},
          :status => 409,
        )
      else
        resource_id = self.serial_id
        self.data[:addresses][resource_id] = resource.merge(
          "provider" => provider_id, "id" => resource_id, "resource_url" => "/addresses/#{resource_id}")

        resource.merge!(
          "provider" => url_for("/providers/#{provider_id}"),
          "location" => resource['location'],
          "address" => url_for("/addresses/#{resource_id}"),
        )

        response(
          :body   => { "untracked_address" => resource },
          :status => 201,
        )
      end
    end
  end # Mock
end # Ey::Core::Client
