class Ey::Core::Client::DatabaseServerSnapshot < Ey::Core::Model
  extend Ey::Core::Associations

  identity :id

  attribute :location
  attribute :engine
  attribute :engine_version
  attribute :storage, type: :integer
  attribute :provisioned_id
  attribute :deleted_at, type: :time
  attribute :provisioned_at, type: :time

  has_one :provider
  has_one :database_server
end
