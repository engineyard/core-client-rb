class Ey::Core::Client::ServerUsage < Ey::Core::Model
  extend Ey::Core::Associations

  attribute :start_at,    type: :time
  attribute :end_at,      type: :time
  attribute :report_time, type: :time
  attribute :flavor
  attribute :dedicated
  attribute :location
  attribute :deis

  has_one :environment
  has_one :provider
end
