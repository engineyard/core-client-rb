class Ey::Core::Client
  class Real
    def boot_environment(params={})
      id = params.delete("id")

      request(
        :path   => "/environments/#{id}/boot",
        :method => :post,
        :body   => params
      )
    end
  end

  class Mock
    def boot_environment(params={})
      params        = Cistern::Hash.stringify_keys(params)
      id            = params.delete("id")
      configuration = params["cluster_configuration"]["configuration"]
      request_id    = self.uuid
      environment   = find(:environments, id)

      servers = {}

      if blueprint_id = params["cluster_configuration"]["blueprint_id"]
        blueprint = find(:blueprints, blueprint_id)

        %w(app_instances db_master db_slaves utils).each do |type|
          blueprint_data = blueprint["data"][type]
          role           = case type
                           when "app_instances" then "app"
                           when "db_master"     then "db_master"
                           when "db_slaves"     then "db_slave"
                           when "utils"         then "util"
                           end
          blueprint_data.each_with_index do |server_data,index|
            role_to_use = (type == 'app_instances' && index == 0) ? "app_master" : role
            server = server_hash(role: role_to_use, environment: environment, flavor: server_data["flavor"]["id"], name: server_data["name"])
            if role_to_use == "app_master"
              if ip_id = params["cluster_configuration"]["ip_id"]
                if find(:addresses, ip_id)
                  server[:address] = url_for("/addresses/#{ip_id}")
                end
              end
            end
            create_volume(server: server, size: server_data["volume_size"], iops: server_data["volume_iops"])
            servers[server["id"]] = server
          end
        end
      else
        case configuration["type"]
        when "solo"
          server = server_hash(environment: environment)
          servers[server["id"]] = server
        when "cluster"
          %w(app_master app db_master).each do |role|
            server = server_hash(role: role, environment: environment)
            servers[server["id"]] = server
            volume_size, iops = if %w(app_master app).include?(role)
                                  [configuration["apps"] ? configuration["apps"]["volume_size"] : 25, nil]
                                elsif %w(db_master db_slave).include?(role)
                                  [configuration["db_master"] ? configuration["db_master"]["volume_size"] : 25, configuration["db_master"] ? configuration["db_master"]["iops"] : nil]
                                end
            create_volume(server: server, volume_size: volume_size, iops: iops)
          end
        when "production-cluster"
          %w(app_master app app db_master db_slave).each do |role|
            server = server_hash(role: role, environment: environment)
            servers[server["id"]] = server
            volume_size, iops = if %w(app_master app).include?(role)
                                  [configuration["apps"] ? configuration["apps"]["volume_size"] : 25, nil]
                                elsif %w(db_master db_slave).include?(role)
                                  [configuration["db_master"] ? configuration["db_master"]["volume_size"] : 25, configuration["db_master"] ? configuration["db_master"]["iops"] : nil]
                                end
            create_volume(server: server, size: volume_size, iops: iops)
          end
        when "custom"
          raise "not implemented"
        end
      end

      self.data[:servers].merge!(servers)

      request = {
        "id"          => request_id,
        "type"        => "boot_environment",
        "successful"  => true,
        "started_at"  => Time.now,
        "finished_at" => nil,
        "resource"    => [:environments, id, environment],
      }

      self.data[:requests][request_id] = request

      response_hash = request.dup
      response_hash.delete("resource")

      response(
        :body    => {"request" => response_hash},
        :status  => 200,
        :headers => {
          "Content-Type" => "application/json; charset=utf8"
        }
      )
    end

    def server_hash(options={})
      id             = self.serial_id
      flavor         = options.delete(:flavor) || "m3_medium"
      role           = options.delete(:role)
      name           = options.delete(:name)
      environment    = options.delete(:environment)
      provisioned_id = "i-#{SecureRandom.hex(4)}"
      provider       = get_providers("account" => environment["account"]).body["providers"].first
      {
        "account"          => url_for("/accounts/#{resource_identity(environment["account"])}"),
        "alerts"           => url_for("/servers/#{id}/alerts"),
        "created_at"       => Time.now.to_s,
        "dedicated"        => !!options[:dedicated],
        "deprovisioned_at" => Time.now.to_s,
        "devices"          => block_device_map,
        "enabled"          => true,
        "environment"      => url_for("/environments/#{environment["id"]}"),
        "flavor"           => { "id" => flavor },
        "id"               => id,
        "location"         => environment["region"],
        "logs"             => url_for("/servers/#{id}/logs"),
        "name"             => name,
        "private_hostname" => "#{provisioned_id}.private.example.org",
        "provider"         => url_for("/providers/#{provider["id"]}"),
        "provisioned_at"   => Time.now.to_s,
        "provisioned_id"   => provisioned_id,
        "public_hostname"  => "#{provisioned_id}.public.example.org",
        "public_key"       => mock_ssh_key[:fingerprint],
        "ssh_port"         => 22,
        "state"            => "running",
        "token"            => SecureRandom.hex(16),
        "updated_at"       => Time.now.to_s,
        "volumes"          => url_for("/servers/#{id}/volumes"),
        "role"             => role || "solo",
      }
    end

    def block_device_map
      [
        {
          "mount"                 => "/",
          "file_system"           => "ext4",
          "device"                => "/dev/sda",
          "size"                  => 100,
          "delete_on_termination" => true,
          "volume_type"           => "gp2",
        },
        {
          "mount"                 => "/mnt",
          "file_system"           => "ext4",
          "device"                => "/dev/sdo",
          "delete_on_termination" => true,
          "size"                  => 100,
          "volume_type"           => "gp2",
        },
        {
          "mount"                 => nil,
          "file_system"           => "swap",
          "device"                => "/dev/sdp",
          "delete_on_termination" => true,
          "size"                  => 8,
          "volume_type"           => "gp2",
        },
        { "device" => "/dev/sdb", "name"   => "ephemeral0", },
      ]
    end

    def create_volume(params={})
      server      = params[:server]
      volume_size = params[:size]
      volume_iops = params[:iops]
      volume_id   = self.serial_id

      self.data[:volumes][volume_id] = {
        "id"     => volume_id,
        "size"   => volume_size,
        "iops"   => volume_iops,
        "server" => url_for("/servers/#{server["id"]}")
      }
    end
  end
end
