class Ey::Core::Client::PlanUsage < Ey::Core::Model
  extend Ey::Core::Associations

  attribute :billable
  attribute :billable_type
  attribute :description
  attribute :end_at,      type: :time
  attribute :flavor_limit
  attribute :report_time, type: :time
  attribute :server_limit
  attribute :start_at,    type: :time
  attribute :support
  attribute :type
end
