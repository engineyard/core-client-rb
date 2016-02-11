class Ey::Core::Client::Volume < Ey::Core::Model
  extend Ey::Core::Associations

  identity :id, type: :integer

  attribute :device
  attribute :file_system
  attribute :format
  attribute :iops, type: :integer
  attribute :location
  attribute :mount
  attribute :mount_options
  attribute :name
  attribute :provisioned_id, type: :string
  attribute :size, type: :integer

  has_one :provider
  has_one :server
  has_one :snapshot
end
