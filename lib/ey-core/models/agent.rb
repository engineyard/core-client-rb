class Ey::Core::Client::Agent < Ey::Core::Model
  extend Ey::Core::Associations

  identity :id

  attribute :created_at,   type: :time
  attribute :host
  attribute :updated_at,   type: :time
  attribute :last_seen_at, type: :time

  has_one :cluster, model: :deis_cluster

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
