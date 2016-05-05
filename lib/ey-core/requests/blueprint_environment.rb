class Ey::Core::Client
  class Real
    def blueprint_environment(params={})
      id = params.delete("id")
      url = params.delete("url")

      request(
        :body   => params,
        :method => :post,
        :path   => "environments/#{id}/blueprint",
        :url    => url,
      )
    end
  end

  class Mock
    def blueprint_environment(params={})
      params        = Cistern::Hash.stringify_keys(params)
      id            = params.delete("id")
      environment   = find(:environments, id)
      blueprint_id  = self.uuid
      servers       = self.data[:servers].values.select { |s| s["environment"] == url_for("/environments/#{id}") && s["deleted_at"].nil? }
      volumes       = servers.inject({}) do |hash,server|
        hash.merge!(server["id"] => self.data[:volumes].values.select { |v| v["server"] == url_for("/servers/#{server["id"]}") })
        hash
      end
      instances = {}
      instances["apps"]      = servers.select { |s| %w(app_master app solo).include?(s["role"]) }
      instances["db_master"] = servers.select { |s| s["role"] == "db_master" }
      instances["db_slaves"] = servers.select { |s| s["role"] == "db_slave" }
      instances["utils"]     = servers.select { |s| s["role"] == "util" }

      %w(apps db_master db_slaves utils).each do |type|
        mapped_types = instances[type].map do |server|
          volume     = volumes[server["id"]].first
          mnt_volume = server["devices"].detect { |d| d["mount"] == "/mnt" }
          {
            "encrypted"       => volume && volume["encrypted"],
            "flavor"          => server["flavor"]["id"],
            "mnt_volume_size" => mnt_volume["size"],
            "name"            => server["name"],
            "volume_iops"     => volume["iops"],
            "volume_size"     => volume["size"]
          }
        end
        instances["blueprint_#{type}"] = mapped_types
      end

      blueprint = {
        "id"          => blueprint_id,
        "account"     => environment["account"],
        "environment" => url_for("/environments/#{id}"),
        "created_at"  => Time.now,
        "updated_at"  => Time.now,
        "name"        => params["name"],
        "data"        => {
          "app_instances" => instances["blueprint_apps"],
          "db_master"     => instances["blueprint_db_master"],
          "db_slaves"     => instances["blueprint_db_slaves"],
          "utils"         => instances["blueprint_utils"],
        }
      }

      self.data[:blueprints][blueprint_id] = blueprint

      response(
        :body   => {"blueprint" => blueprint},
        :status => 200,
      )
    end
  end
end
