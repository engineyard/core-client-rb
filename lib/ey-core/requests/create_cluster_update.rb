class Ey::Core::Client
  class Real
    def create_cluster_update(params={})
      cluster_id = params.delete("cluster")
      url        = params.delete("url")

      request(
        :body   => params,
        :method => :post,
        :path   => "/clusters/#{cluster_id}/updates",
        :url    => url,
      )
    end
  end # Real

  class Mock
    def create_cluster_update(params={})
      extract_url_params!(params)

      request_id = self.uuid

      cluster_id  = resource_identity(params["cluster"])
      cluster_url = url_for("/clusters/#{cluster_id}")

      cluster           = find(:clusters, cluster_id)
      provider_url      = cluster["provider"]
      provider          = find(:providers, provider_url)
      location          = cluster["location"]["id"]

      block_device_map  =       [
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

      procedure = lambda do |_|
        # TODO: dependencies?

        unless provider["type"] == "azure"
          firewalls = cluster["configuration"]["firewalls"] rescue []

          # create new firewalls
          existing_firewalls = self.data[:cluster_firewalls].inject([]) { |r, (c_id, f_id)| c_id == cluster_id ? r << self.data[:firewalls][f_id] : r }
          new_firewalls      = firewalls.reject { |f| existing_firewalls.find {|ef| ef["name"] == f["name"] } }

          new_firewalls.each do |firewall|
            request = create_firewall({
              "provider" => provider_url,
              "cluster" => cluster,
              "firewall" => {
                "name" => firewall["name"],
              },
            })
            get_request("id" => request.body["request"]["id"])
          end

          # create new firewall rules
          firewalls.each do |firewall|
            firewall_id = search(self.data[:firewalls], "name" => firewall["name"]).keys.first

            existing_rules = search(self.data[:firewalls], "firewall" => url_for("/firewalls/#{firewall_id}")).values
            new_rules      = firewall["rules"].reject {|r| existing_rules.detect {|er| er.port_range == r["port_range"] && er.source == r["source"] } }

            new_rules.each do |rule|
              request = create_firewall_rule({
                "firewall" => firewall_id,
                "firewall_rule" => rule,
              })
              get_request("id" => request.body["request"]["id"])
            end
          end
        end

        # deprovision servers for retired slots
        slots = self.data[:slots].values.select{|s|
          next unless s["cluster"] == cluster_url
          if s["retired_at"]
            s["deleted_at"] = Time.now.to_s

            if server_id = resource_identity(s["server"])
              self.data[:servers][server_id]["deleted_at"] = Time.now.to_s
            end
          end
          s["deleted_at"].nil?
        }

        # provision new servers for empty slots
        slots.select{|s| s["server"].nil?}.each do |slot|
          server_id = self.serial_id
          provisioned_id = self.uuid[0..6]

          # create server
          self.data[:servers][server_id] = {
            "alerts"           => url_for("/servers/#{server_id}/alerts"),
            "cluster"          => url_for("/clusters/#{cluster["id"]}"),
            "created_at"       => Time.now.to_s,
            "deprovisioned_at" => Time.now.to_s,
            "devices"          => block_device_map,
            "enabled"          => true,
            "environment"      => cluster["environment"],
            "events"           => url_for("/servers/#{server_id}/events"),
            "firewalls"        => url_for("/servers/#{server_id}/firewalls"),
            "flavor"           => { "id" => slot["flavor"] },
            "id"               => server_id,
            "location"         => location,
            "logs"             => url_for("/servers/#{server_id}/logs"),
            "name"             => slot["name"],
            "private_hostname" => "#{provisioned_id}.private.example.org",
            "provider"         => provider_url,
            "provisioned_at"   => Time.now.to_s,
            "provisioned_id"   => provisioned_id,
            "public_hostname"  => "#{provisioned_id}.public.example.org",
            "public_key"       => mock_ssh_key[:fingerprint],
            "slot"             => url_for("/slots/#{slot["id"]}"),
            "ssh_port"         => 22,
            "state"            => "running",
            "token"            => SecureRandom.hex(16),
            "updated_at"       => Time.now.to_s,
            "volumes"          => url_for("/servers/#{server_id}/volumes"),
          }

          slot["server"] = url_for("/slots/#{slot["id"]}/server")

          # create volumes
          if volumes = slot["configuration"] && slot["configuration"]["volumes"]
            volumes.each do |volume|
              volume_id = self.serial_id
              self.data[:volumes][volume_id] = volume.merge({
                "id"             => volume_id,
                "location"       => location,
                "provider"       => provider_url,
                "provisioned_id" => "vol-#{SecureRandom.hex(4)}",
                "server"         => url_for("/servers/#{server_id}"),
              })
            end
          end
        end

        # chef log for every server
        slots.each do |slot|
          log = create_log("log" => {
            "filename"            => "command.txt",
            "server"              => slot["server"],
          }).body["log"]

          # hax to support searching cluster & cluster update logs
          self.data[:logs][log["id"]].merge!({
            "_cluster"        => slot["cluster"],
            "_cluster_update" => url_for("/cluster-updates/#{request_id}"),
          })
        end

        url_for("/cluster-updates/#{request_id}")
      end

      cluster_update = {
        "finished_at" => nil,
        "id"          => request_id,
        "started_at"  => Time.now.to_s,
        "successful"  => "true",
        "cluster"     => cluster_url,
        "logs"        => url_for("/cluster-updates/#{request_id}/logs"),
        "stage"       => "activate",
      }

      request = cluster_update.merge(
        "resource" => [:cluster_updates, request_id, procedure],
        "type"     => "cluster_update",
      )

      self.data[:requests][request_id] = request
      self.data[:cluster_updates][request_id] = cluster_update

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
  end # Mock
end # Ey::Core::Client
