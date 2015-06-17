class Ey::Core::Client::DatabaseServer < Ey::Core::Model
  extend Ey::Core::Associations

  identity :id

  attribute :location
  attribute :flavor
  attribute :engine
  attribute :version
  attribute :storage, type: :integer
  attribute :endpoint
  attribute :provisioned_id
  attribute :modifiers

  attribute :deleted_at, type: :time

  has_one :provider
  has_one :database_service
  has_one :replication_source, resource: :database_server

  has_many :firewalls
  has_many :messages
  has_many :snapshots, model: :database_server_snapshots
  has_many :revisions, model: :database_server_revisions
  has_many :alerts

  def save!
    requires :replication_source, :provider_id

    params = {
      "url"              => self.collection.url,
      "provider"         => self.provider_id,
      "database_server"  => {
        "replication_source" => self.replication_source_id,
      },
    }

    if new_record?
      self.connection.requests.new(self.connection.create_database_server(params).body["request"])
    else
      raise NotImplementedError
    end
  end

  def destroy!
    connection.requests.new(self.connection.destroy_database_server("id" => self.id).body["request"])
  end

  def master?
    !replication_source
  end

  def discover
    connection.requests.new(connection.discover_database_server("id" => self.identity).body["request"])
  end
end
