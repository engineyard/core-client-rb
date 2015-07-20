class Ey::Core::Client::Cost < Ey::Core::Model
  extend Ey::Core::Associations

  attribute :billing_month
  attribute :data_type
  attribute :level
  attribute :finality
  attribute :related_resource_type
  attribute :category
  attribute :units
  attribute :description
  attribute :value

  has_one :account
  has_one :environment
end
