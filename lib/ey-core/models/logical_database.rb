class Ey::Core::Client::LogicalDatabase < Ey::Core::Model
  extend Ey::Core::Associations

  identity :id

  attribute :name
  attribute :username
  attribute :password
  attribute :created_at, type: :time
  attribute :updated_at, type: :time
  attribute :deleted_at, type: :time
  attribute :extensions, type: :array

  attribute :db_service_id
  attribute :db_service_name
  attribute :db_engine_type
  attribute :db_master_multi_az
  attribute :db_master_flavor
  attribute :db_replica_count
  attribute :connected_kubey_cluster_count

  has_one :service, resource: :database_service
  has_many :environments

  def kubey_environment=(arg)
    @kubey_environment = arg
  end

  def save!
    requires :name

    params = {
      "url"              => self.collection.url,
      "database_service" => self.service_id,
      "logical_database" => Cistern::Hash.slice(attributes, :name, :extensions),
    }
    if @kubey_environment
      params.merge!("environment" => @kubey_environment.id, "kubey" => true)
    end

    if new_record?
      self.connection.requests.new(self.connection.create_logical_database(params).body["request"])
    else raise NotImplementedError
    end
  end

  def destroy!
    connection.requests.new(self.connection.destroy_logical_database("id" => self.id).body["request"])
  end

  def connect(cluster_component, configuration={})
    requires :identity

    self.connection.connectors.create(source: self, destination: cluster_component, configuration: configuration)
  end
end
