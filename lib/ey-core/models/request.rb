class Ey::Core::Client::Request < Ey::Core::Model
  include Ey::Core::Subscribable

  identity :id

  attribute :callback_url
  attribute :created_at,        type: :time
  attribute :finished_at,       type: :time
  attribute :message
  attribute :progress,          type: :integer
  attribute :resource_url,      aliases: "resource"
  attribute :stage
  attribute :started_at,        type: :time
  attribute :successful,        type: :boolean
  attribute :type
  attribute :updated_at,        type: :time

  def callback
    merge_attributes(connection.request_callback(self.id).body["request"])
  end

  def ready!(timeout = self.service.timeout, interval = self.service.poll_interval)
    wait_for!(timeout, interval) { ready? }
    raise Ey::Core::RequestFailure.new(self) unless successful?
    self
  end

  def ready?
    !!self.finished_at
  end

  def successful?
    self.successful
  end

  def resource!(timeout = self.service.timeout, interval = self.service.poll_interval)
    ready!(timeout, interval); resource
  end

  def resource
    return nil unless resource_url
    resource_id = resource_url.split("/").last
    case type
    when /address/
      self.connection.addresses.get!(resource_id)
    when /cluster_update/
      self.connection.cluster_updates.get!(resource_id)
    when /database_server_snapshot/
      collection, id = resource_url.split('/')[-3..-2]
      if collection == "providers"
        connection.providers.get!(id).database_server_snapshots
      elsif collection == "database-servers"
        connection.database_servers.get!(id).snapshots
      else
        connection.database_server_snapshots.get!(resource_id)
      end
    when /database_server/
      self.connection.database_servers.get!(resource_id)
    when /database_service/
      self.connection.database_services.get!(resource_id)
    when /firewall(?!_rule)/
      self.connection.firewalls.get!(resource_id)
    when /firewall_rule/
      self.connection.firewall_rules.get!(resource_id)
    when /logical_database/
      self.connection.logical_databases.get!(resource_id)
    when /provider_location/
      self.connection.provider_locations.get!(resource_id)
    when /provider_storage_credential/
      self.connection.storage_users.get!(resource_id)
    when /provider_storage/
      self.connection.storages.get!(resource_id)
    when /provider/
      self.connection.providers.get!(resource_id)
    when /server/
      self.connection.servers.get!(resource_id)
    when /snapshot/
      self.connection.snapshots.get!(resource_id)
    when /task/
      self.connection.tasks.get!(resource_id)
    when /volume/
      self.connection.volumes.get!(resource_id)
    when /load_balancer/
      self.connection.load_balancers.get!(resource_id)
    when /ssl_certificate/
      self.connection.ssl_certificates.get!(resource_id)
    else
      nil # has no coresponding resource
    end
  end
end
