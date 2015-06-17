class Ey::Core::Client::ClusterComponent < Ey::Core::Model
  extend Ey::Core::Associations

  identity :id

  attribute :configuration
  attribute :created_at, type: :time
  attribute :deleted_at, type: :time
  attribute :name
  attribute :position, type: :integer
  attribute :updated_at, type: :time

  has_one :application
  has_one :cluster
  has_one :component

  has_many :connectors
  has_many :tasks
  has_many :keypairs

  # @param destination [Ey::Core::Client::ClusterComponent]
  # @param configuration [Hash]
  def connect(destination, configuration={})
    requires :identity

    self.connection.connectors.create(source: self, destination: destination, configuration: configuration)
  end

  def run(action, params={})
    requires :identity

    response = self.connection.run_cluster_component_action(
      "action"            => action,
      "cluster_component" => self.identity,
      "task"              => params,
    )
    connection.requests.new(response.body["request"])
  end

  def save!
    params = {
      "url"               => self.collection.url,
      "component"         => self.component_id,
      "cluster"           => self.cluster_id,
      "cluster_component" => {
        "configuration" => configuration,
      },
    }

    if new_record?
      merge_attributes(self.connection.create_cluster_component(params).body["cluster_component"])
    else
      params = {
        "id" => id,
        "cluster_component" => {
          "configuration" => configuration,
        }
      }
      merge_attributes(self.connection.update_cluster_component(params).body["cluster_component"])
    end
  end
end
