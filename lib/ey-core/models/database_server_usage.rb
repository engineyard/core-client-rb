class Ey::Core::Client::DatabaseServerUsage < Ey::Core::Model
  extend Ey::Core::Associations

  attribute :start_at,    type: :time
  attribute :end_at,      type: :time
  attribute :report_time, type: :time
  attribute :flavor
  attribute :provisioned_id
  attribute :location
  attribute :multi_az
  attribute :master

  has_one :database_service
  has_one :provider
end
