class Ey::Core::Client::DeisCluster < Ey::Core::Model
  extend Ey::Core::Associations

  identity :id

  attribute :created_at, type: :time
  attribute :name
  attribute :registration_token
  attribute :updated_at, type: :time

  has_many :agents

  def save!
    if self.identity
      raise NotImplementedError
    else
      requires :name

      merge_attributes(
        connection.create_deis_cluster(
          "deis_cluster" => { "name" => self.name },
          "url"          => self.collection.url,
        ).body["deis_cluster"]
      )
    end
  end
end
