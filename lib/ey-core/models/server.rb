class Ey::Core::Client::Server < Ey::Core::Model
  extend Ey::Core::Associations

  identity :id, type: :integer

  attribute :created_at, type: :time
  attribute :deleted_at, type: :time
  attribute :deprovisioned_at, type: :time
  attribute :disappeared_at, type: :time
  attribute :devices, type: :array
  attribute :enabled, type: :boolean
  attribute :flavor_id, squash: ["flavor", "id"]
  attribute :keymaster_id
  attribute :legacy_role
  attribute :location
  attribute :name
  attribute :private_hostname
  attribute :provisioned_at, type: :time
  attribute :provisioned_id
  attribute :public_hostname
  attribute :ssh_port, type: :integer
  attribute :state
  attribute :updated_at, type: :time

  has_one :account
  has_one :address, collection: "addresses"
  has_one :cluster
  has_one :environment
  has_one :provider
  has_one :slot

  has_many :alerts
  has_many :volumes
  has_many :events, key: :server_events
  has_many :firewalls

  def reboot
    requires :identity

    params = {
      "url" => self.collection.url,
      "id"  => self.identity,
    }

    connection.requests.new(
      self.connection.reboot_server(params).body["request"]
    )
  end

  def save!
    requires :identity

    server_attributes = Cistern::Hash.slice(Cistern::Hash.stringify_keys(self.attributes), "provisioned_at", "deprovisioned_at", "disappeared_at")
    server_attributes.merge!("status" => self.state) if self.state

    connection.update_server(
      "id"     => self.identity,
      "server" => server_attributes,
    )
  end

  def destroy!
    requires :identity

    connection.requests.new(
      self.connection.destroy_server(self.identity).body["request"]
    )
  end
end
