class Ey::Core::Client::ProviderLocation < Ey::Core::Model
  extend Ey::Core::Associations

  identity :id

  attribute :location_id
  attribute :location_name
  attribute :limits, type: :hash

  has_one :provider
end
