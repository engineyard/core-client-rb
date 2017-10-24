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
      resource_id       = self.serial_id
      app_deployment_id = self.serial_id
      application_id    = params["environment"].delete("application_id")
      url               = params.delete("url")
      application       = find(:applications, application_id)

      account_id ||= params["account"] || url && path_params(url)["accounts"]

      find(:accounts, account_id)

      resource = params["environment"].dup

      internal_key = mock_ssh_key

      resource.merge!(
        "account"               => url_for("/accounts/#{account_id}"),
        "applications"          => url_for("/environments/#{resource_id}/applications"),
        "classic"               => true,
        "clusters"              => url_for("/environments/#{resource_id}/clusters"),
        "created_at"            => Time.now,
        "custom_recipes"        => nil,
        "database_stack"        => "postgres9_4",
        "deployments_url"       => url_for("/environments/#{resource_id}/deployments"),
        "id"                    => resource_id,
        "internal_private_key"  => internal_key[:private_key],
        "internal_public_key"   => internal_key[:public_key],
        "keypairs"              => url_for("/environments/#{resource_id}/keypairs"),
        "logical_databases_url" => url_for("/environments/#{resource_id}/logical-databases"),
        "release_label"         => "stable-v4-2.0.101",
        "servers"               => url_for("/environments/#{resource_id}/servers"),
        "stack_name"            => "nginx_passenger4",
        "updated_at"            => Time.now,
        "username"              => "deploy",
        "service_level"         => "default",
        "cdn_distributions"     => url_for("/environments/#{resource_id}/cdn-distributions")
      )

      self.data[:environments][resource_id] = resource

      if service_id = params["environment"]["database_service"]
        self.requests.new(create_logical_database(
          "database_service" => service_id,
          "logical_database" => {
            "name" => "#{resource["name"]}_#{application["name"]}"
          }
        ).body["request"]).ready!
      end

      self.data[:application_deployments][app_deployment_id] = {
        :environment_id => resource_id,
        :application_id => application_id,
      }

      response(
        :body   => {"environment" => resource},
        :status => 201,
      )
    end
  end # Mock
end # Ey::Core::Client
