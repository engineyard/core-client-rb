class Ey::Core::Client::ClusterUpdate < Ey::Core::Model
  extend Ey::Core::Associations

  identity :id

  attribute :created_at, type: :time
  attribute :started_at, type: :time
  attribute :finished_at, type: :time
  attribute :deleted_at, type: :time
  attribute :error
  attribute :message
  attribute :stage
  attribute :successful, type: :boolean
  attribute :updated_at, type: :time

  has_one :cluster

  has_many :logs
  has_many :dependencies, key: :requests

  def save!
    params = {
      "url"     => self.collection.url,
      "cluster" => self.cluster_id,
    }

    if new_record?
      connection.requests.new(self.connection.create_cluster_update(params).body["request"])
    else raise NotImplementedError # update
    end
  end
end
