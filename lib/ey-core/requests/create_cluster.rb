class Ey::Core::Client
  class Real
    def create_cluster(params={})
      environment_id = params["environment"]
      url            = params.delete("url")

      request(
        :method => :post,
        :path   => "/environments/#{environment_id}/clusters",
        :body   => params,
        :url    => url,
      )
    end
  end # Real

  class Mock
    def create_cluster(params={})
      extract_url_params!(params)

      environment = find(:environments, params["environment"])

      resource_id = self.uuid
      resource    = params["cluster"].dup
      provider_id = resource["provider"]
      location    = resource.delete("location")

      provider = find(:providers, provider_id)

      provider_location = self.data[:provider_locations].values.find do |pl|
        pl["provider"] == url_for("/providers/#{provider_id}") && pl["location_id"] == location
      end

      unless provider_location
        return response(
          :status => 422,
          :body   => {"errors" => ["Don't have access to #{location}"]},
        )
      end

      resource.merge!(
        "backups"     => url_for("/clusters/#{resource_id}/backups"),
        "components"  => url_for("/clusters/#{resource_id}/components"),
        "created_at"  => Time.now,
        "environment" => url_for("/environments/#{environment["id"]}"),
        "firewalls"   => url_for("/clusters/#{resource_id}/firewalls"),
        "id"          => resource_id,
        "location"    => {"id" => provider_location["location_id"], "name" => provider_location["name"]},
        "provider"    => url_for("/providers/#{provider_id}"),
        "servers"     => url_for("/clusters/#{resource_id}/servers"),
        "slots"       => url_for("/clusters/#{resource_id}/slots"),
        "updated_at"  => Time.now,
        "updates"     => url_for("/clusters/#{resource_id}/updates"),
      )

      resource["configuration"] = normalize_hash(resource["configuration"] || {})
      resource["configuration"]["version"] ||= 0
      resource["configuration"]["ha_strategy"] ||= "noop"

      case provider["type"]
      when "azure"
        resource["configuration"]["hosted_services"] ||= []

        unless resource["configuration"]["hosted_services"].first
          resource["configuration"]["hosted_services"] << {
            "name"  => "#{resource_id[0..6]}-hosted-service",
            "endpoints" => []
          }
        end
      else
        resource["configuration"]["firewalls"] ||= []

        if default_firewall = resource["configuration"]["firewalls"].first
          ssh_rule = { "source" => "0.0.0.0/0", "port_range" => 22 }
          unless (default_firewall["rules"] || []).include? ssh_rule
            default_firewall["rules"] << ssh_rule
          end
        else
          resource["configuration"]["firewalls"] << {
            "name"  => "#{resource_id[0..6]}-firewall",
            "rules" => [
              {
                "source"     => "0.0.0.0/0",
                "port_range" => "22",
              }
            ]
          }
        end
      end

      self.data[:clusters][resource_id] = resource

      response(
        :body   => {"cluster" => resource},
        :status => 201,
      )
    end
  end # Mock
end # Ey::Core::Client
