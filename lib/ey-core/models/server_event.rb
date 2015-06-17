class Ey::Core::Client::ServerEvent < Ey::Core::Model
  extend Ey::Core::Associations

  identity :id

  attribute :type
  attribute :created_at, type: :time
  attribute :updated_at, type: :time

  has_one :server
end
