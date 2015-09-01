class Ey::Core::Client::Agent < Ey::Core::Model
  extend Ey::Core::Associations

  identity :id

  attribute :created_at,   type: :time
  attribute :host
  attribute :updated_at,   type: :time
  attribute :last_seen_at, type: :time

  has_one :cluster, model: :deis_cluster

  def save!
    raise NotImplementedError
  end
end
