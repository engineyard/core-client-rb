class Ey::Core::Client::LegacyAlert < Ey::Core::Model
  extend Ey::Core::Associations

  identity :id, type: :integer

  attribute :type
  attribute :created_at, type: :time
  attribute :severity
  attribute :acknowledged, type: :boolean

  has_one :server
end
