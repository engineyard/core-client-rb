class Ey::Core::Client
  class Real
    def create_environment(params={})
      account_id  = params["account"]
      url         = params.delete("url")

      request(
        :body   => params,
        :method => :post,
        :path   => "/accounts/#{account_id}/environments",
        :url    => url,
      )
    end
  end # Real

  class Mock
    def create_environment(params={})
      resource_id = self.serial_id
      url         = params.delete("url")

      if project_id = params["project"] || url && path_params(url)["projects"]
        account_id = resource_identity(find(:projects, project_id)["account"])
      end
      account_id ||= params["account"] || url && path_params(url)["accounts"]

      find(:accounts, account_id)

      resource = params["environment"].dup

      internal_key = mock_ssh_key

      resource.merge!(
        "account"               => url_for("/accounts/#{account_id}"),
        "applications"          => url_for("/environments/#{resource_id}/applications"),
        "classic"               => false,
        "clusters"              => url_for("/environments/#{resource_id}/clusters"),
        "created_at"            => Time.now,
        "database_services_url" => url_for("/environments/#{resource_id}/database-services"),
        "id"                    => resource_id,
        "internal_private_key"  => internal_key[:private_key],
        "internal_public_key"   => internal_key[:public_key],
        "keypairs"              => url_for("/environments/#{resource_id}/keypairs"),
        "logical_databases_url" => url_for("/environments/#{resource_id}/logical-databases"),
        "project"               => project_id && url_for("/projects/#{project_id}"),
        "servers"               => url_for("/environments/#{resource_id}/servers"),
        "updated_at"            => Time.now,
      )

      self.data[:environments][resource_id] = resource

      response(
        :body   => {"environment" => resource},
        :status => 201,
      )
    end
  end # Mock
end # Ey::Core::Client
