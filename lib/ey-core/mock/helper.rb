module Ey::Core::Mock
  module Helper
    def create_database_service_resource(params)
      database_service    = params["database_service"]
      logical_database    = params["logical_database"]
      database_service_id = database_service.fetch("id")
      database_server     = params["database_server"]
      provider_id         = params["provider_id"]

      contact_attributes = %w[name phone_number email title]
      contacts = Array(database_service["contacts"]).inject([]) do |r, contact|
        require_parameters(contact, *contact_attributes)

        r << Cistern::Hash.slice(contact, *contact_attributes).merge!(
          "id"         => self.uuid,
          "created_at" => Time.now.to_s,
          "updated_at" => Time.now.to_s,
          "deleted_at" => nil,
        )
      end

      database_service.merge!(
        "id"           => database_service_id,
        "resource_url" => "/database-services/#{database_service_id}",
        "provider"     => url_for("/providers/#{provider_id}"),
        "servers"      => url_for("/database-services/#{database_service_id}/servers"),
        "databases"    => url_for("/database-services/#{database_service_id}/databases"),
        "messages"     => url_for("/database-services/#{database_service_id}/messages"),
        "snapshots"    => url_for("/database-services/#{database_service_id}/snapshots"),
        "contacts"     => url_for("/database-services/#{database_service_id}/contacts"),
        "deleted_at"   => nil,
      )

      engine, location, _ = require_parameters(database_server, "engine", "location", "flavor", "version")
      database_server_id = self.uuid

      port = case engine
             when /postgres/i then 5432
             when /mysql/i then 3306
             else 9922
             end

      database_server.merge!(
        "id"               => database_server_id,
        "provisioned_id"   => "#{database_service["name"].downcase}master",
        "database_service" => url_for("/database-services/#{database_service_id}"),
        "provider"         => url_for("/providers/#{provider_id}"),
        "firewalls"        => url_for("/database-servers/#{database_server_id}/firewalls"),
        "alerts"           => url_for("/database-servers/#{database_server_id}/alerts"),
        "endpoint"         => "#{engine}://root@localhost:#{port}",
        "messages"         => url_for("/database-servers/#{database_server_id}/messages"),
        "snapshots"        => url_for("/database-servers/#{database_server_id}/snapshots"),
        "revisions"        => url_for("/database-servers/#{database_server_id}/revisions"),
        "deleted_at"       => nil,
      )

      firewall_id = self.serial_id

      #@todo: add service level and contacts
      #
      lambda do |r|

        self.data[:firewalls][firewall_id] = {
          "id"             => firewall_id,
          "name"           => SecureRandom.hex(4),
          "provisioned_id" => SecureRandom.hex(10),
          "resource_url"   => "/firewalls/#{firewall_id}",
          "provider"       => url_for("/providers/#{provider_id}"),
          "clusters"       => url_for("/firewalls/#{firewall_id}/clusters"),
          "location"       => location.gsub(/[a-z]$/, ""),
          "rules"          => url_for("/firewalls/#{firewall_id}/rules")
        }

        self.data[:database_server_firewalls] << [database_server_id, firewall_id]
        self.data[:database_servers][database_server_id] = database_server
        self.data[:database_services][database_service_id] = database_service

        contacts.each { |contact|
          self.data[:contacts][contact.fetch("id")] = contact
          self.data[:contact_assignments] << [contact.fetch("id"), database_service.fetch("id")]
        }

        if logical_database # only on bootstrap
          self.data[:logical_databases][logical_database.fetch("id")] = logical_database
        end

        database_server.delete("resource_url")
        database_service.delete("resource_url")
        r.delete("resource_url")
      end
    end

    def create_feature(params)
      params = Cistern::Hash.stringify_keys(params)

      params["id"]      ||= self.serial_id
      params["privacy"] ||= "private"
      params["name"]    ||= params["id"]

      self.data[:features][params["id"]] = params
      self.features.new(params)
    end
  end
end
