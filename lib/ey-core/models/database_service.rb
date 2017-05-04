class Ey::Core::Client::DatabaseService < Ey::Core::Model
  extend Ey::Core::Associations

  identity :id

  attribute :location
  attribute :name
  attribute :deleted_at, type: :time
  attribute :service_level

  attribute :db_service_id
  attribute :db_service_name
  attribute :db_engine_type
  attribute :db_master_multi_az
  attribute :db_master_flavor
  attribute :db_replica_count
  attribute :connected_kubey_cluster_count
  attribute :vpc_name
  attribute :vpc_provisioned_id

  has_one :provider

  has_many :databases, model: :logical_databases
  has_many :servers,   model: :database_servers
  has_many :snapshots, model: :database_server_snapshots
  has_many :connected_kubey_environments, model: :environments

  # @todo remove me next major revision
  attr_accessor :database_server

  def save!
    requires :name, :provider_id

    server_info  = self.servers.map { |c| c.is_a?(Ey::Core::Client::DatabaseServer) ? c.attributes : c }

    server_info += [database_server] if database_server

    if server_info.size > 1
      raise ArgumentError, "only one server can be specified"
    elsif server_info.size < 1
      raise ArgumentError, "you must specify at least one server dude"
    end

    params = {
      "url"              => self.collection.url,
      "provider"         => self.provider_id,
      "database_server"  => server_info.first,
      "database_service" => {
        "name"          => self.name,
        "service_level" => self.service_level,
      },
    }

    if new_record?
      self.connection.requests.new(self.connection.create_database_service(params).body["request"])
    else raise NotImplementedError
    end
  end

  def destroy!
    connection.requests.new(self.connection.destroy_database_service("id" => self.id).body["request"])
  end
end
