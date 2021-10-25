class Ey::Core::Client
  class Real
    def deploy_environment_application(options={})
      id = options.delete("id")

      request(
        :path   => "/environments/#{id}/deploy",
        :method => :post,
        :body   => options,
      )
    end
  end

  class Mock
    def deploy_environment_application(options={})
      environment_id = options.delete("id")
      application_id = options.delete("application_id")
      request_id     = self.uuid
      deployment_id  = self.serial_id

      response(status: 422) unless self.data[:application_deployments].values.detect { |ad| ad[:environment_id] == environment_id && ad[:application_id] == application_id }

      deployment = {
        "account"         => find(:environments, environment_id)["account"],
        "application"     => url_for("/applications/#{application_id}"),
        "commit"          => options["deploy"]["ref"],
        "environment"     => url_for("/environments/#{environment_id}"),
        "finished_at"     => Time.now,
        "id"              => deployment_id,
        "migrate_command" => options["deploy"]["migrate"] ? (options["deploy"]["migrate_command"] || "rake db:migrate") : nil,
        "migrate"         => options["deploy"]["migrate"] || false,
        "resolved_ref"    => options["deploy"]["ref"],
        "serverside_version"    => options["deploy"]["serverside_version"],
        "started_at"      => Time.now,
        "successful"      => true
      }

      self.data[:deployments][deployment_id] = deployment

      request = {
        "id"           => request_id,
        "type"         => "app_deployment",
        "successful"   => true,
        "started_at"   => Time.now,
        "finished_at"  => nil,
        "resource_url" => url_for("/environments/#{environment_id}"),
        "resource"     => [:environments, environment_id, find(:environments, environment_id)]
      }

      self.data[:requests][request_id] = request

      response_hash = request.dup
      response_hash.delete("resource")

      response(
        :body   => {"request" => response_hash},
        :status => 201,
      )
    end
  end
end
