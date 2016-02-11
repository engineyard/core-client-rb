class Ey::Core::Client
  class Real
    def create_server(params={})
      request(
        :method => :post,
        :path   => "/servers",
        :url    => params.delete("url"),
        :body   => params,
      )
    end
  end

  class Mock
    def create_server(params={})
      params = Cistern::Hash.stringify_keys(params)
      server = params["server"]

      require_parameters(params, "environment")
      require_parameters(params["server"], "role", "location", "flavor")
      if server["role"] == "util"
        require_parameters(params["server"], "name")
      end

      request_id     = self.uuid
      resource_id    = self.serial_id
      provisioned_id = "i-#{SecureRandom.hex(4)}"
      environment_id = resource_identity(params["environment"])
      environment    = find(:environments, environment_id)
      account        = resource_identity(environment["account"])
      provider       = self.data[:providers].values.detect { |p| p["account"] == url_for("/accounts/#{account}") }

      servers = self.data[:servers].values.select { |s| s["environment"] == url_for("/environments/#{environment_id}") }

      if servers.count == 1 && servers.first["role"] == "solo" && server["role"] == "db_slave"
        response(
          :status => 422,
          :body   => {"errors" => ["Cannot add a DB Slave"]},
        )
      end

      resource = {
        "account"          => url_for("/accounts/#{account}"),
        "alerts"           => url_for("/servers/#{resource_id}/alerts"),
        "created_at"       => Time.now.to_s,
        "deprovisioned_at" => nil,
        "devices"          => block_device_map(server),
        "enabled"          => true,
        "environment"      => url_for("/environments/#{environment["id"]}"),
        "flavor"           => { "id" => server["flavor"] },
        "id"               => resource_id,
        "location"         => environment["region"],
        "logs"             => url_for("/servers/#{resource_id}/logs"),
        "name"             => server["name"],
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
        "volumes"          => url_for("/servers/#{resource_id}/volumes"),
        "role"             => server["role"],
      }

      request = {
        "id"           => request_id,
        "type"         => "provision_server",
        "successful"   => "true",
        "started_at"   => Time.now,
        "finished_at"  => nil,
        "resource_url" => url_for("/servers/#{resource_id}"),
        "resource"     => [:servers, resource_id, resource],
      }

      self.data[:requests][request_id] = request

      response_hash = request.dup
      response_hash.delete("resource")

      response(
        :body   => {"request" => response_hash},
        :status => 201,
      )
    end

    def block_device_map(params={})
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
          "size"                  => params["mnt_volume_size"] || 100,
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
  end
end
