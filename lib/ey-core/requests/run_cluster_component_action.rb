class Ey::Core::Client
  class Real
    def run_cluster_component_action(params={})
      cluster_component_id = params.delete("cluster_component")
      action               = params.delete("action")
      url                  = params.delete("url")

      request(
        :body   => params,
        :method => :post,
        :path   => "/cluster-components/#{cluster_component_id}/actions/#{action}",
        :url    => url,
      )
    end
  end # Real

  class Mock
    def run_cluster_component_action(params={})
      cluster_component_id = params.delete("cluster_component")
      action               = params.delete("action")

      request_id = self.uuid

      cluster_component = find(:cluster_components, cluster_component_id)

      task = {
        "action"                 => action,
        "application_deployment" => nil,
        "cluster_component"      => url_for("/cluster-components/#{cluster_component_id}"),
        "configuration"          => normalize_hash(params["task"] || {}),
        "created_at"             => Time.now,
        "finished_at"            => nil,
        "id"                     => request_id,
        "resource_url"           => url_for("/tasks/#{request_id}"),
        "started_at"             => Time.now,
        "successful"             => true,
        "updated_at"             => Time.now,
        "component_actions"      => url_for("/tasks/#{request_id}/component-actions")
      }

      if action == "backup"
        create_backup(
          "backup" => {},
          "url"    => cluster_component["cluster"],
        )
      end

      # application component
      default_deployer = self.data[:components].values.find {|c| c["name"] == "default_deployer" }
      if cluster_component["component"] == url_for("/components/#{default_deployer["id"]}")
        application_id            = cluster_component["configuration"]["application"]
        application_deployment_id = self.uuid
        archive_id                = task["configuration"]["archive_id"]

        find(:applications, application_id)

        if action == "deploy"
          unless cluster_component["configuration"].has_key?("enabled")
            cluster_component["configuration"]["enabled"] = true
          end

          application_deployment = {
            "application"        => url_for("/applications/#{application_id}"),
            "archive"            => archive_id && url_for("/applications/#{application_id}/archives/#{archive_id}"),
            "commit"             => task["configuration"]["commit"] || "123456789abcdefghijklmnopqrstuvwxyz12345",
            "created_at"         => Time.now,
            "finished_at"        => nil,
            "id"                 => application_deployment_id,
            "migrate"            => !! task["configuration"]["migrate"] || true,
            "migrate_command"    => task["configuration"]["migrate_command"] || "bundle exec rake db:migrate",
            "ref"                => task["configuration"]["ref"] || "HEAD",
            "serverside_version" => "2.2.0",
            "started_at"         => Time.now,
            "successful"         => task["successful"],
            "task"               => url_for("/tasks/#{request_id}"),
          }
          task.merge!("application_deployment" => url_for("/application_deployments/#{application_deployment_id}"))

          self.data[:application_deployments][application_deployment_id] = application_deployment
        end

        if action == "enable"
          cluster_component["configuration"]["enabled"] = true
        end

        if action == "disable"
          cluster_component["configuration"]["enabled"] = false
        end

        serverside_command = case action
                             when "deploy"
                               "echo 'I am a fake engineyard-serverside deploy command'"
                             when "enable"
                               "echo 'I am a fake engineyard-serverside disable_maintenance command'"
                             when "disable"
                               "echo 'I am a fake engineyard-serverside enable_maintenance command'"
                             when "restart"
                               "echo 'I am a fake engineyard-serverside restart command'"
                             else
                               raise "Application components do not respond to action '#{action}'"
                             end

        create_component_action(task, serverside_command)
        create_component_action(task, "echo 'I am a fake engineyard-serverside maintenance_status command'")
      end

      task.merge!("read_channel" => "https://messages.engineyard.com/stream?subscription=/tasks/#{request_id[0..7]}&token=#{SecureRandom.hex(6)}")

      request = task.merge(
        "type"        => "task",
        "started_at"  => Time.now,
        "finished_at" => nil,
        "successful"  => true,
        "id"          => request_id,
        "resource"    => [:tasks, request_id, lambda do |r|
          application_deployment["finished_at"] = Time.now if application_deployment

          r.delete("resource_url")
        end],
      )


      self.data[:requests][request_id] = request
      self.data[:tasks][request_id]    = task

      response_hash = request.dup
      response_hash.delete("resource")

      response(
        :body    => {"request" => response_hash},
        :status  => 201,
        :headers => {
          "Content-Type" => "application/json; charset=utf8"
        }
      )
    end

    protected

    def create_component_action(task, serverside_command)
      # emit a component action for the serverside call
      cluster_component = find(:cluster_components, task["cluster_component"])
      cluster     = find(:clusters, cluster_component["cluster"])
      environment = find(:environments, cluster["environment"])

      component_action_id = self.uuid
      component_action = {
        "id"                     => component_action_id,
        "created_at"             => Time.now,
        "finished_at"            => Time.now,
        "started_at"             => Time.now,
        "updated_at"             => Time.now,
        "successful"             => true,
      }

      self.data[:requests][component_action_id] = component_action.merge("resource_url" => url_for("/component-actions/#{component_action_id}"))

      component_action.merge!({
        "account"   => environment["account"],
        "logs"      => url_for("/component-actions/#{component_action_id}/logs"),
        "command"   => serverside_command,
        "exit_code" => 0,
        "task"      => task["resource_url"],
      })

      self.data[:component_actions][component_action_id] = component_action

      log_id = self.uuid
      log = {
        "id"               => log_id,
        "filename"         => "command.txt",
        "upload_url"       => "https://a-fake-log-url/",
        "download_url"     => "https://a-fake-log-url/",
        "mime_type"        => "text/plain",
        "component_action" => url_for("/component-actions/#{component_action_id}"),
      }

      self.data[:logs][log_id] = log
    end
  end # Mock
end # Ey::Core::Client
