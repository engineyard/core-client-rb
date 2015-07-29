class Ey::Core::Client::DatabaseService < Ey::Core::Model
  extend Ey::Core::Associations

  identity :id

  attribute :location
  attribute :name
  attribute :deleted_at, type: :time
  attribute :service_level

  has_one :provider

  has_many :contacts
  has_many :databases, model: :logical_databases
  has_many :servers,   model: :database_servers
  has_many :snapshots, model: :database_server_snapshots

  # @todo remove me next major revision
  attr_accessor :database_server

  def save!
    requires :name, :provider_id

    contact_info = self.contacts.map { |c| c.is_a?(Ey::Core::Client::Contact) ? c.attributes : c }
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
        "contacts"      => contact_info,
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
