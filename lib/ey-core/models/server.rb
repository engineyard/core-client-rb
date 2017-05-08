class Ey::Core::Client::Server < Ey::Core::Model
  extend Ey::Core::Associations

  identity :id, type: :integer

  attribute :chef_status,      type: :array
  attribute :created_at,       type: :time
  attribute :deleted_at,       type: :time
  attribute :deprovisioned_at, type: :time
  attribute :devices,          type: :array
  attribute :disappeared_at,   type: :time
  attribute :enabled,          type: :boolean
  attribute :flavor_id,        squash: ["flavor", "id"]
  attribute :keymaster_id
  attribute :location
  attribute :name
  attribute :private_hostname
  attribute :provisioned_at,   type: :time
  attribute :provisioned_id
  attribute :public_hostname
  attribute :public_key
  attribute :role
  attribute :ssh_port,         type: :integer
  attribute :state
  attribute :token
  attribute :updated_at,       type: :time
  attribute :wait_for_chef,    type: :boolean
  attribute :release_label

  has_one :account
  has_one :address, collection: "addresses"
  has_one :environment
  has_one :provider
  has_one :latest_chef_log, collection: "logs", resource: 'log'

  has_many :alerts
  has_many :volumes
  has_many :events, key: :server_events
  has_many :firewalls
  has_many :logs

  attr_accessor :mnt_volume_size, :volume_size, :iops, :snapshot_id, :force

  def apply(type="main")
    requires :identity

    connection.requests.new(self.connection.apply_server_updates("id" => self.identity, "type" => type).body["request"])
  end

  def latest_main_log
    logs.select{|l| l.filename.match(/main/)}.sort_by(&:created_at).last
  end

  def latest_custom_log
    logs.select{|l| l.filename.match(/custom/)}.sort_by(&:created_at).last
  end

  def reboot
    requires :identity

    connection.requests.new(
      self.connection.reboot_server("id" => self.identity).body["request"]
    )
  end

  def stop
    requires :identity

    connection.requests.new(
      self.connection.stop_server("id" => self.identity).body["request"]
    )
  end

  def start
    requires :identity

    connection.requests.new(
      self.connection.start_server("id" => self.identity).body["request"]
    )
  end

  def reconcile
    requires :identity

    connection.requests.new(
      self.connection.reconcile_server("id" => self.identity).body["request"]
    )
  end

  def reset_state(state)
    params = {
      "url"   => self.collection.url,
      "id"    => self.id,
      "state" => state
    }

    unless new_record?
      merge_attributes(self.connection.reset_server_state(params).body["server"])
    end
  end

  def save!
    if new_record?
      requires :flavor_id, :role, :environment

      server_attributes = {
        "environment" => environment.id,
        "wait_for_chef" => self.wait_for_chef,
        "snapshot"    => self.snapshot_id,
        "force"       => self.force,
        "server"      => {
          "flavor"          => self.flavor_id,
          "iops"            => self.iops,
          "location"        => self.location || environment.region,
          "mnt_volume_size" => self.mnt_volume_size,
          "name"            => self.name,
          "role"            => self.role,
          "volume_size"     => self.volume_size,
          "release_label"   => self.release_label,
        }
      }
      connection.requests.new(connection.create_server(server_attributes).body["request"])
    else
      requires :identity
      server_attributes = Cistern::Hash.slice(Cistern::Hash.stringify_keys(self.attributes), "provisioned_at", "deprovisioned_at", "disappeared_at")
      server_attributes.merge!("status" => self.state) if self.state
      connection.update_server(
        "id"     => self.identity,
        "server" => server_attributes,
      )
    end
  end

  def destroy!
    if environment.servers.count == 1
      raise Ey::Core::Client::NotPermitted, "Terminating the last server in an environment is not allowed.  You must deprovision or destroy the environment instead."
    end

    requires :identity

    connection.requests.new(
      self.connection.destroy_server(self.identity).body["request"]
    )
  end
end
